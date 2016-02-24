import Foundation
import Alamofire
import RealmSwift
import SKMaps
import BrightFutures

class DownloadService {
  
  static var downloadPath: String!
  static let gcsMapsUrl = "https://storage.googleapis.com/tripfinger-maps/"
  static let gcsImagesUrl = "https://storage.googleapis.com/tripfinger-images/"
  

  class func hasMapPackage(packageId: String) -> Bool {
    let mapPackages = SKMapsService.sharedInstance().packagesManager.installedOfflineMapPackages as! [SKMapPackage]
    for mapPackage in mapPackages {
      if mapPackage.name == packageId {
        return true
      }
    }
    return false
  }
  
  class func isCountryDownloaded(region: Region) -> Bool {
    return hasMapPackage(region.getName())
  }
  
  class func deleteCountry(countryName: String) {
    deleteTripfingerImagesForRegion(countryName)
    deleteMapForRegion(countryName)
    DatabaseService.deleteCountry(countryName)
  }
  
  class func deleteTripfingerImagesForRegion(countryName: String, cityName: String! = nil) {
    let path = NSURL.getDirectory(.LibraryDirectory, withPath: countryName)
    if cityName != nil {
      path.URLByAppendingPathComponent(cityName)
    }
    NSURL.deleteFolder(path)
    
  }
  
  class func deleteMapForRegion(mapPackageCode: String) {
    SKMapsService.sharedInstance().packagesManager.deleteOfflineMapPackageNamed(mapPackageCode)
  }
  
  class func downloadCountry(countryName: String, onlyMap: Bool = false, progressHandler: Float -> (), finishedHandler: () -> ()) {
    
    UIApplication.sharedApplication().idleTimerDisabled = true

    let countryPath = NSURL.createDirectory(.LibraryDirectory, withPath: countryName)
    var finished = true
    if !hasMapPackage(countryName) {
      finished = false
      try! downloadMapForCountry(countryName, regionPath: countryPath, progressHandler: progressHandler) {
        if finished {
          UIApplication.sharedApplication().idleTimerDisabled = false
          finishedHandler()
        }
        else {
          finished = true
        }
      }
    }
    if !onlyMap {
      downloadTripfingerData(AppDelegate.serverUrl + "/download_country/\(countryName)", path: countryPath) {
        if finished {
          finishedHandler()
        }
        else {
          finished = true
        }
      }
    }
  }
  
//  class func downloadCity(countryName: String, cityName: String, onlyMap: Bool = false, progressHandler: Float -> (), finishedHandler: () -> ()) {
//    
//    let countryPath = NSURL.createDirectory(.LibraryDirectory, withPath: countryName)
//    var finished = false
//    let cityPath = countryPath.URLByAppendingPathComponent(cityName)
//    
//    try! downloadMapForRegion(cityName, regionPath: cityPath, progressHandler: progressHandler) {
//      if finished {
//        finishedHandler()
//      }
//      else {
//        finished = true
//      }
//    }
//    if !onlyMap {
//      downloadTripfingerData(tripfingerUrl + "/download_city/\(cityName)", path: cityPath) {
//        if finished {
//          finishedHandler()
//        }
//        else {
//          finished = true
//        }
//      }
//    }
//  }
  
  class func resumeDownloadsIfNecessary() {
  }
  
  class func downloadMapForCountry(countryName: String, regionPath: NSURL, progressHandler: Float -> (), finishedHandler: () -> ()) throws {
    
    let escapedCountryName = countryName.stringByAddingPercentEncodingWithAllowedCharacters(.URLPathAllowedCharacterSet())!
    if hasMapPackage(countryName) {
      throw Error.RuntimeError("Map for \(countryName) is already installed.")
    }
    
    print("path: \(regionPath.path)")
    let dispatchGroup = dispatch_group_create();
    
    var fileName = countryName + ".skm"
    var url = gcsMapsUrl + escapedCountryName + ".skm"
    var destinationPath = regionPath.URLByAppendingPathComponent(fileName)
    NetworkUtil.saveDataFromUrl(url, destinationPath: destinationPath, dispatchGroup: dispatchGroup, progressHandler: progressHandler)
    fileName = countryName + ".ngi"
    url = gcsMapsUrl + escapedCountryName + ".ngi"
    destinationPath = regionPath.URLByAppendingPathComponent(fileName)
    NetworkUtil.saveDataFromUrl(url, destinationPath: destinationPath, dispatchGroup: dispatchGroup, progressHandler: nil)
    
    fileName = countryName + ".ngi.dat"
    url = gcsMapsUrl + escapedCountryName + ".ngi.dat"
    destinationPath = regionPath.URLByAppendingPathComponent(fileName)
    NetworkUtil.saveDataFromUrl(url, destinationPath: destinationPath, dispatchGroup: dispatchGroup, progressHandler: nil)
    
    fileName = countryName + ".txg"
    url = gcsMapsUrl + escapedCountryName + ".txg"
    destinationPath = regionPath.URLByAppendingPathComponent(fileName)
    NetworkUtil.saveDataFromUrl(url, destinationPath: destinationPath, dispatchGroup: dispatchGroup, progressHandler: nil)
    
    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue()) {
      SKMapsService.sharedInstance().packagesManager.addOfflineMapPackageNamed(countryName, inContainingFolderPath: regionPath.path!)
      finishedHandler()
    }
  }
  
  class func downloadTripfingerData(url: String, path: NSURL, finishedHandler: () -> ()) {
    
    var parameters = [String: String]()
    if AppDelegate.mode != AppDelegate.AppMode.RELEASE {
      parameters["onlyPublished"] = "false"
    }
    
    NetworkUtil.getJsonFromUrl(url, parameters: parameters, success: {
      json in
      
      let region = JsonParserService.parseRegionTreeFromJson(json)
      
      let dispatchGroup = dispatch_group_create()
      fetchImages(region, path: path, dispatchGroup: dispatchGroup)
      
      try! DatabaseService.saveRegion(region)
      
      dispatch_group_notify(dispatchGroup, dispatch_get_main_queue()) {
        print("Finished image downloads")
        finishedHandler()
      }
    })
    
  }
  
  class func fetchImages(region: Region, path: NSURL, dispatchGroup: dispatch_group_t) {
    fetchImages(region.item(), path: path, dispatchGroup: dispatchGroup)
    for attraction in region.attractions {
      fetchImages(attraction.listing.item, path: path, dispatchGroup: dispatchGroup)
    }
  }
  
  class func getLocalPartOfFileUrl(fileUrl: NSURL) -> String {
    let pathIndex = fileUrl.absoluteString.rangeOfString("/Library/", options: NSStringCompareOptions.BackwardsSearch)
    return fileUrl.absoluteString.substringFromIndex(pathIndex!.endIndex)
  }
  
  class func fetchImages(guideItem: GuideItem, path: NSURL, dispatchGroup: dispatch_group_t) {
    for image in guideItem.images {
      let index = gcsImagesUrl.startIndex.advancedBy(gcsImagesUrl.characters.count)
      let fileName = image.url.substringFromIndex(index)
      let destinationPath = path.URLByAppendingPathComponent(fileName)
      NetworkUtil.saveDataFromUrl(image.url, destinationPath: destinationPath, dispatchGroup: dispatchGroup)
      image.url = getLocalPartOfFileUrl(destinationPath)
    }
    for guideSection in guideItem.guideSections {
      fetchImages(guideSection.item, path: path, dispatchGroup: dispatchGroup)
    }
    for categoryDescription in guideItem.categoryDescriptions {
      fetchImages(categoryDescription.item, path: path, dispatchGroup: dispatchGroup)
    }
    for subRegion in guideItem.subRegions {
      let subPath = NSURL.appendToDirectory(path, pathElement: subRegion.getName())
      fetchImages(subRegion, path: subPath, dispatchGroup: dispatchGroup)
    }
  }
}

//class MapDownloadManager: NSObject, SKTDownloadManagerDelegate, SKTDownloadManagerDataSource {
//  
//  var finishedHandler: (() -> ())?
//  var progressHandler: (Float -> ())?
//  
//  func downloadManager(downloadManager: SKTDownloadManager, didUpdateCurrentDownloadProgress  currentPorgressString: String, currentDownloadPercentage currentPercentage: Float, overallDownloadProgress overallProgressString: String, overallDownloadPercentage overallPercentage: Float, forDownloadHelper downloadHelper: SKTDownloadObjectHelper) {
//    if let progressHandler = progressHandler {
//      progressHandler(currentPercentage / 100.0)
//    }
//  }

//  func downloadManager(downloadManager: SKTDownloadManager, didDownloadDownloadHelper downloadHelper: SKTDownloadObjectHelper, withSuccess success: Bool) {
//    print("Finished downloading map.")
//    SKMapsService.sharedInstance().packagesManager.addOfflineMapPackageNamed("regionId", inContainingFolderPath: "regionPath.path!")
//    
//    if let finishedHandler = finishedHandler {
//      finishedHandler()
//    }
//  }
//  
//  func downloadManager(downloadManager: SKTDownloadManager, saveDownloadHelperToDatabase downloadHelper: SKTDownloadObjectHelper) {
//    print("SAVE to DB")
//    let code: String = downloadHelper.getCode()
//    let path: String = SKTDownloadManager.libraryDirectory() + "/" + code
//    //        let path: NSURL = SKTDownloadManager.libraryDirectory().stringByAppendingPathComponent(downloadHelper.getCode())
//    print("Fetching from: \(path)")
//    
//    SKMapsService.sharedInstance().packagesManager.addOfflineMapPackageNamed(code, inContainingFolderPath: path)
//    
//    let fman: NSFileManager = NSFileManager()
//    try! fman.removeItemAtPath(path)
//  }
//  
//  func operationsCancelledByOSDownloadManager(downloadManager: SKTDownloadManager!) {
//    print("OP_CANCELLED_BY_OS")
//  }
//  
//  func didPauseDownload() {
//    print("DIDPAUSEDOWNLOAD")
//  }
//  
//  func downloadManager(downloadManager: SKTDownloadManager!, didPauseDownloadForDownloadHelper downloadHelper: SKTDownloadObjectHelper!) {
//    print("DWN_MNG_DIDPAUSEDOWNLOAD")
//  }
//  
//  func didCancelDownload() {
//    print("DIDCANCELDOWNLOAD")
//  }
//  
//  func downloadManager(downloadManager: SKTDownloadManager!, didCancelDownloadForDownloadHelper downloadHelper: SKTDownloadObjectHelper!) {
//    print("DWN_MNG_DIDCANCELDOWNLOAD")
//  }
//  
//  func isOnBoardMode() -> Bool {
//    return false
//  }
//}