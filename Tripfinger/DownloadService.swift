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
  
  class func isRegionDownloaded(regionId: String, countryId: String? = nil) -> Bool {
    
    if hasMapPackage(regionId) {
      return true
    }
    else if let countryId = countryId {
      return hasMapPackage(countryId)
    }
    else {
      return false
    }
  }
  
  class func getMapsAvailable() -> Future<(SKTMapsObject, [String: String]), NoError> {
    let promise = Promise<(SKTMapsObject, [String: String]), NoError>()
    
    Queue.global.async {
      let jsonURLString = SKMapsService.sharedInstance().packagesManager.mapsJSONURLForVersion(nil)
      ContentService.getJsonStringFromUrl(jsonURLString, success: {
        json in
        
        let skMaps = SKTMapsObject.convertFromJSON(json)
        let allContinents = skMaps.packagesForType(.Continent) as! [SKTPackage]
        let countries = skMaps.packagesForType(.Country) as! [SKTPackage]
        var names = getPackageNames(countries)
        names.appendContentsOf(getPackageNames(allContinents))
        let jsonNames = JSON(rawValue: names)!
        
        ContentService.getJsonFromPost(ContentService.baseUrl + "/region_ids", body: jsonNames.rawString()!, success: {
          json in
          
          var mappings = [String: String]()
          let jsonDict = json.dictionary!
          for country in countries {
            mappings[country.packageCode] = jsonDict[country.nameForLanguageCode("en")]!.string!
          }
          for continent in allContinents {
            mappings[continent.packageCode] = jsonDict[continent.nameForLanguageCode("en")]!.string!
          }

          promise.success((skMaps, mappings))
          }, failure: nil)
      })
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
  
  class func hasMapPackage(packageId: String) -> Bool {
    let mapPackages = SKMapsService.sharedInstance().packagesManager.installedOfflineMapPackages as! [SKMapPackage]
    for mapPackage in mapPackages {
      if mapPackage.name == packageId {
        return true
      }
    }
    return false
  }
  
  class func deleteRegion(regionId: String, countryId: String) {
    deleteTripfingerDataForRegion(regionId, countryId: countryId)
    deleteMapForRegion(regionId)
    OfflineService.deleteRegionWithId(regionId)
  }
  
  class func deleteTripfingerDataForRegion(regionId: String, countryId: String) {
    let path = NSURL.getDirectory(.LibraryDirectory, withPath: countryId)
    if regionId != countryId {
      path.URLByAppendingPathComponent(regionId)
    }
    NSURL.deleteFolder(path)
    
  }
  
  class func deleteMapForRegion(regionId: String) {
    SKMapsService.sharedInstance().packagesManager.deleteOfflineMapPackageNamed(regionId)
  }
  
  class func downloadCountry(countryId: String, package: SKTPackage, onlyMap: Bool = false, progressHandler: Float -> (), finishedHandler: () -> ()) {
    
    let countryPath = NSURL.getDirectory(.LibraryDirectory, withPath: countryId)
    var finished = false
    try! downloadMapForRegion(countryId, regionPath: countryPath, package: package, progressHandler: progressHandler) {
      if finished {
        finishedHandler()
      }
      else {
        finished = true
      }
    }
    if !onlyMap {
      downloadTripfingerData(tripfingerUrl + "/download_country/\(countryId)", path: countryPath) {
        if finished {
          finishedHandler()
        }
        else {
          finished = true
        }
      }
    }
  }
  
  class func downloadCity(countryId: String, cityId: String, package: SKTPackage, onlyMap: Bool = false, progressHandler: Float -> (), finishedHandler: () -> ()) {
    
    let countryPath = NSURL.getDirectory(.LibraryDirectory, withPath: countryId)
    var finished = false
    let cityPath = countryPath.URLByAppendingPathComponent(cityId)
    
    try! downloadMapForRegion(cityId, regionPath: cityPath, package: package, progressHandler: progressHandler) {
      if finished {
        finishedHandler()
      }
      else {
        finished = true
      }
    }
    if !onlyMap {
      downloadTripfingerData(tripfingerUrl + "/download_city/\(cityId)", path: cityPath) {
        if finished {
          finishedHandler()
        }
        else {
          finished = true
        }
      }      
    }
  }
  
  class func downloadMapForRegion(regionId: String, regionPath: NSURL, package: SKTPackage, progressHandler: Float -> (), finishedHandler: () -> ()) throws {
    if hasMapPackage(regionId) {
      throw Error.RuntimeError("Map for \(regionId) is already installed.")
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
    Alamofire.request(.GET, url)
      .responseData { response in
        if response.result.isSuccess {
          
          let json = JSON(data: response.data!)
          let region = ContentService.parseRegionTreeFromJson(json)
          
          fetchImages(region, path: path)

          try! OfflineService.saveRegion(region)
          
          finishedHandler()
        }
        else {
          print("ERROR: Downloading city JSON failed")
        }
    }
  }
  
  class func fetchImages(region: Region, path: NSURL) {
    var imageList = getImageList(region.listing.item)
    imageList.appendContentsOf(getImageList(region))
    downloadImages(imageList, path: path)
    for subRegion in region.listing.item.subRegions {
      let subPath = NSURL.appendToDirectory(path, pathElement: region.getId())
      fetchImages(subRegion, path: subPath)
    }
  }
  
  class func getImageList(region: Region) -> [GuideItemImage] {
    var imageList = [GuideItemImage]()
    for attraction in region.attractions {
      for image in attraction.listing.item.images {
        imageList.append(image)
      }
    }
    return imageList
  }
  
  class func getImageList(guideItem: GuideItem) -> [GuideItemImage] {
    var imageList = [GuideItemImage]()
    for image in guideItem.images {
      imageList.append(image)
    }
    for guideSection in guideItem.guideSections {
      imageList.appendContentsOf(getImageList(guideSection.item))
    }
    return imageList
  }
  
  class func downloadImages(imageList: [GuideItemImage], path: NSURL) {
    for image in imageList {
      let nsUrl = NSURL(string: image.url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!
      Alamofire.request(.GET, nsUrl)
        .responseData { response in
          let index: String.Index = gcsImagesUrl.startIndex.advancedBy(gcsImagesUrl.characters.count)
          let fileName = image.url.substringFromIndex(index)
          let destinationPath = path.URLByAppendingPathComponent(fileName)
          print("Writing image to file: \(fileName)")
          if response.result.isSuccess {
            let result = response.data?.writeToURL(destinationPath, atomically: true)
            if !result! {
              print("ERROR: Writing file failed")
            }
          }
          else {
            print("ERROR: Downloading image failed: \(fileName)")
            print("response: \(response.response?.statusCode)")
          }
      }
      
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