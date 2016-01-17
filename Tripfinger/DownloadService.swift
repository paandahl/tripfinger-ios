import Foundation
import Alamofire
import RealmSwift
import SKMaps
import BrightFutures

class DownloadService {
  
  static let tripfingerUrl = "https://server.tripfinger.com"
  static let gcsMapsUrl = "https://storage.googleapis.com/tripfinger-maps/"
  static let gcsImagesUrl = "https://storage.googleapis.com/tripfinger-maps/"
  
  static var mapDownloadManager = MapDownloadManager()
  
  class func isRegionDownloaded(mapsObject: SKTMapsObject, country: Region, city: Region! = nil) -> Bool {
    
    if hasMapPackageForRegion(country, mapsObject: mapsObject) {
      return true
    } else if city != nil {
      return hasMapPackageForRegion(city, mapsObject: mapsObject)
    } else {
      return false
    }
  }
  
  class func getSKTMapsObject() -> Future<SKTMapsObject, Error> {
    let promise = Promise<SKTMapsObject, Error>()
    
    let mapsFileUrl = NSURL.getDirectory(.LibraryDirectory, withPath: "mapsObject.json")
    if NSURL.fileExists(.LibraryDirectory, withPath: "mapsObject.json") {
      let json = JSON(data: NSData(contentsOfURL: mapsFileUrl)!).rawString()!
      let skMaps = SKTMapsObject.convertFromJSON(json)
      print("loaded mapsObject from file")
      promise.success(skMaps)
      
    } else {
      Queue.global.async {
        let jsonURLString = SKMapsService.sharedInstance().packagesManager.mapsJSONURLForVersion(nil)
        ContentService.getJsonStringFromUrl(jsonURLString, success: {
          json in
          
          try! json.writeToURL(mapsFileUrl, atomically: true, encoding: NSUTF8StringEncoding)
          
          let skMaps = SKTMapsObject.convertFromJSON(json)
          print("loaded mapsObject from url")
          promise.success(skMaps)
          }, failure: {
            promise.failure(Error.DownloadError("Could not download file."))
        })
      }
    }
    
    
    return promise.future
  }
  
  internal class func getPackageNames(packages: [SKTPackage]) -> [String] {
    var names = [String]()
    for package in packages {
      names.append(package.nameForLanguageCode("en"))
    }
    return names
  }

  class func hasMapPackage(type: SKTPackageType, name: String, mapsObject: SKTMapsObject) -> Bool {
    let mapPackages = mapsObject.packagesForType(type) as! [SKTPackage]
    for mapPackage in mapPackages {
      if mapPackage.nameForLanguageCode("en") == name {
        return hasMapPackage(mapPackage.packageCode)
      }
    }
    return false
  }

  class func hasMapPackage(packageId: String) -> Bool {
    let mapPackages = SKMapsService.sharedInstance().packagesManager.installedOfflineMapPackages as! [SKMapPackage]
    for mapPackage in mapPackages {
      if mapPackage.name == packageId {
        return true
      }
    }
    return false
  }
  

  class func hasMapPackageForRegion(region: Region, mapsObject: SKTMapsObject!) -> Bool {
    
    var packageType: SKTPackageType
    switch region.item().category {
    case Region.Category.COUNTRY.rawValue:
      packageType = SKTPackageType.Country
    case Region.Category.CITY.rawValue:
      packageType = SKTPackageType.City
    default:
      return false
    }

    return hasMapPackage(packageType, name: region.getName(), mapsObject: mapsObject)
  }
  


  class func deleteRegion(mapPackageCode: String, countryName: String, cityName: String! = nil) {
    deleteTripfingerDataForRegion(countryName, cityName: cityName)
//    deleteMapForRegion(mapPackageCode)
    OfflineService.deleteRegion(countryName, cityName: cityName)
  }

  class func deleteTripfingerDataForRegion(countryName: String, cityName: String! = nil) {
    let path = NSURL.getDirectory(.LibraryDirectory, withPath: countryName)
    if cityName != nil {
      path.URLByAppendingPathComponent(cityName)
    }
    NSURL.deleteFolder(path)
    
  }
  
  class func deleteMapForRegion(mapPackageCode: String) {
    SKMapsService.sharedInstance().packagesManager.deleteOfflineMapPackageNamed(mapPackageCode)
  }
  
  class func downloadCountry(mapsObject: SKTMapsObject, countryName: String, package: SKTPackage, onlyMap: Bool = false, progressHandler: Float -> (), finishedHandler: () -> ()) {
    
    let countryPath = NSURL.createDirectory(.LibraryDirectory, withPath: countryName)
    var finished = true
    if !hasMapPackage(.Country, name: countryName, mapsObject: mapsObject) {
      finished = false
      try! downloadMapForRegion(countryName, regionPath: countryPath, package: package, progressHandler: progressHandler) {
        if finished {
          finishedHandler()
        }
        else {
          finished = true
        }
      }
    }
    if !onlyMap {
      downloadTripfingerData(tripfingerUrl + "/download_country/\(countryName)", path: countryPath) {
        if finished {
          finishedHandler()
        }
        else {
          finished = true
        }
      }
    }
  }
  
  class func downloadCity(countryName: String, cityName: String, package: SKTPackage, onlyMap: Bool = false, progressHandler: Float -> (), finishedHandler: () -> ()) {
    
    let countryPath = NSURL.createDirectory(.LibraryDirectory, withPath: countryName)
    var finished = false
    let cityPath = countryPath.URLByAppendingPathComponent(cityName)
    
    try! downloadMapForRegion(cityName, regionPath: cityPath, package: package, progressHandler: progressHandler) {
      if finished {
        finishedHandler()
      }
      else {
        finished = true
      }
    }
    if !onlyMap {
      downloadTripfingerData(tripfingerUrl + "/download_city/\(cityName)", path: cityPath) {
        if finished {
          finishedHandler()
        }
        else {
          finished = true
        }
      }
    }
  }
  
  class func downloadMapForRegion(regionName: String, regionPath: NSURL, package: SKTPackage, progressHandler: Float -> (), finishedHandler: () -> ()) throws {
    if hasMapPackage(package.packageCode) {
      throw Error.RuntimeError("Map for \(regionName) is already installed.")
    }
    
    print("path: \(regionPath.path)")
    
    let region: SKTDownloadObjectHelper =  SKTDownloadObjectHelper.downloadObjectHelperWithSKTPackage(package) as! SKTDownloadObjectHelper
    mapDownloadManager.progressHandler = progressHandler
    mapDownloadManager.finishedHandler = finishedHandler
    SKTDownloadManager.sharedInstance().requestDownloads([region], startAutomatically: true, withDelegate: mapDownloadManager, withDataSource: mapDownloadManager, withPath: regionPath.path!)
    
    
    //    var fileName = regionId + ".skm"
    //    var url = gcsMapsUrl + fileName
    //    var destinationPath = regionPath.URLByAppendingPathComponent(fileName)
    //    downloadFile(url, destinationPath: destinationPath, progressHandler: progressHandler) {
    //      SKMapsService.sharedInstance().packagesManager.addOfflineMapPackageNamed(regionId, inContainingFolderPath: regionPath.path!)
    //      finishedHandler()
    //    }
    //
    //    fileName = regionId + ".ngi"
    //    url = gcsMapsUrl + fileName
    //    destinationPath = regionPath.URLByAppendingPathComponent(fileName)
    //    downloadFile(url, destinationPath: destinationPath, progressHandler: nil, finishedHandler: nil)
    //
    //    fileName = regionId + ".ngi.dat"
    //    url = gcsMapsUrl + fileName
    //    destinationPath = regionPath.URLByAppendingPathComponent(fileName)
    //    downloadFile(url, destinationPath: destinationPath, progressHandler: nil, finishedHandler: nil)
    //
    //    fileName = regionId + ".txg"
    //    url = gcsMapsUrl + fileName
    //    destinationPath = regionPath.URLByAppendingPathComponent(fileName)
    //    downloadFile(url, destinationPath: destinationPath, progressHandler: nil, finishedHandler: nil)
  }
  
  class func downloadTripfingerData(url: String, path: NSURL, finishedHandler: () -> ()) {
    
    NetworkUtil.getJsonFromUrl(url, success: {
      json in
      
      let region = ContentService.parseRegionTreeFromJson(json)
      
      fetchImages(region, path: path)
      
      try! OfflineService.saveRegion(region)
      
      finishedHandler()
    })
    
  }
  
  class func fetchImages(region: Region, path: NSURL) {
    fetchImages(region.item(), path: path)
    for attraction in region.attractions {
      fetchImages(attraction.listing.item, path: path)
    }
  }
  
  class func fetchImages(guideItem: GuideItem, path: NSURL) { //TODO: fix so that image urls are replaced by offline urls
    for image in guideItem.images {
      let index = gcsImagesUrl.startIndex.advancedBy(gcsImagesUrl.characters.count)
      let fileName = image.url.substringFromIndex(index)
      let destinationPath = path.URLByAppendingPathComponent(fileName)
      NetworkUtil.saveDataFromUrl(image.url, destinationPath: destinationPath)
      let pathIndex = destinationPath.absoluteString.rangeOfString("/Library/")
      image.url = destinationPath.absoluteString.substringFromIndex(pathIndex!.endIndex)
    }
    for guideSection in guideItem.guideSections {
      fetchImages(guideSection.item, path: path)
    }
    for categoryDescription in guideItem.categoryDescriptions {
      fetchImages(categoryDescription.item, path: path)
    }
    for subRegion in guideItem.subRegions {
      let subPath = NSURL.appendToDirectory(path, pathElement: subRegion.getName())
      fetchImages(subRegion, path: subPath)
    }
  }
  
  class func downloadFile(url: String, destinationPath: NSURL, progressHandler: (Float -> ())?, finishedHandler: (() -> ())?) {
    Alamofire.request(.GET, url)
      .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
        
        if let progressHandler = progressHandler {
          let progress = Float(totalBytesRead) / Float(totalBytesExpectedToRead)
          
          dispatch_async(dispatch_get_main_queue()) {
            progressHandler(progress)
          }
        }
      }
      .responseData { response in
        
        print("Writing file to disk: \(destinationPath.absoluteString)")
        if response.result.isSuccess {
          let result = response.data?.writeToURL(destinationPath, atomically: true)
          if !result! {
            print("ERROR: Writing file failed")
          }
          if let finishedHandler = finishedHandler {
            finishedHandler()
          }
        }
        else {
          print("ERROR: Downloading file failed")
        }
    }
  }
}

class MapDownloadManager: NSObject, SKTDownloadManagerDelegate, SKTDownloadManagerDataSource {
  
  var finishedHandler: (() -> ())?
  var progressHandler: (Float -> ())?
  
  func downloadManager(downloadManager: SKTDownloadManager, didUpdateCurrentDownloadProgress  currentPorgressString: String, currentDownloadPercentage currentPercentage: Float, overallDownloadProgress overallProgressString: String, overallDownloadPercentage overallPercentage: Float, forDownloadHelper downloadHelper: SKTDownloadObjectHelper) {
    if let progressHandler = progressHandler {
      progressHandler(currentPercentage / 100.0)
    }
  }
  
  func downloadManager(downloadManager: SKTDownloadManager, didDownloadDownloadHelper downloadHelper: SKTDownloadObjectHelper, withSuccess success: Bool) {
    print("Finished downloading region.")
    SKMapsService.sharedInstance().packagesManager.addOfflineMapPackageNamed("regionId", inContainingFolderPath: "regionPath.path!")
    
    if let finishedHandler = finishedHandler {
      finishedHandler()
    }
  }
  
  func downloadManager(downloadManager: SKTDownloadManager, saveDownloadHelperToDatabase downloadHelper: SKTDownloadObjectHelper) {
    print("SAVE to DB")
    let code: String = downloadHelper.getCode()
    let path: String = SKTDownloadManager.libraryDirectory() + "/" + code
    //        let path: NSURL = SKTDownloadManager.libraryDirectory().stringByAppendingPathComponent(downloadHelper.getCode())
    print("Fetching from: \(path)")
    
    SKMapsService.sharedInstance().packagesManager.addOfflineMapPackageNamed(code, inContainingFolderPath: path)
    
    let fman: NSFileManager = NSFileManager()
    do {
      try fman.removeItemAtPath(path)
    } catch {
      
    }
  }
  
  
  func isOnBoardMode() -> Bool {
    return false
  }
}