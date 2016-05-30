import Foundation
import Alamofire
import RealmSwift
import BrightFutures

class DownloadService {
  
  static var downloadPath: String!
  static let gcsMapsUrl = "https://storage.googleapis.com/tripfinger-maps/"
  static let gcsImagesUrl = "https://storage.googleapis.com/tripfinger-images/"
  

  class func hasMapPackage(packageId: String) -> Bool {
//    let mapPackages = SKMapsService.sharedInstance().packagesManager.installedOfflineMapPackages as! [SKMapPackage]
//    for mapPackage in mapPackages {
//      if mapPackage.name == packageId {
//        return true
//      }
//    }
    return false
  }
  
  class func isCountryDownloaded(countryName: String) -> Bool {
    return DatabaseService.getCountry(countryName) != nil
  }

  class func isCountryDownloading(mwmRegionId: String) -> Bool {
    return DatabaseService.hasDownloadMarker(mwmRegionId) && !DatabaseService.isDownloadMarkerCancelled(mwmRegionId)
  }
  
  class func cancelDownload(mwmRegionId: String) {
    DatabaseService.setCancelledOnDownloadMarker(mwmRegionId)
  }

  class func deleteCountry(countryName: String) {
    deleteTripfingerImagesForRegion(countryName)
    DatabaseService.deleteCountry(countryName)
  }
  
  class func deleteTripfingerImagesForRegion(countryName: String, cityName: String! = nil) {
    let path = NSURL.getDirectory(.LibraryDirectory, withPath: countryName)
    if cityName != nil {
      path.URLByAppendingPathComponent(cityName)
    }
    NSURL.deleteFolder(path)
  }
  
  class func resumeDownloads() {
    let countriesToResume = DatabaseService.getCountriesWithDownloadMarkers()
    for countryToResume in countriesToResume {
      downloadCountry(countryToResume.country, progressHandler: { progress in
        MapsAppDelegateWrapper.updateDownloadProgress(progress, forMwmRegion: countryToResume.country)
        }, failure: {}, finishedHandler: {})
    }
  }
  
  class func downloadCountry(mwmRegionId: String, progressHandler: Double -> (), failure: () -> (), finishedHandler: () -> ()) {
    
    DatabaseService.addDownloadMarker(mwmRegionId)
    let application = UIApplication.sharedApplication()
    application.idleTimerDisabled = true
    var taskHandle = UIBackgroundTaskInvalid
    taskHandle = application.beginBackgroundTaskWithExpirationHandler {
      print("expiration handler called")
      application.endBackgroundTask(taskHandle)
      taskHandle = UIBackgroundTaskInvalid
    }

    ContentService.getCountryWithName(mwmRegionId, failure: {}) { region in
      let countryPath = NSURL.createDirectory(.LibraryDirectory, withPath: region.getName())
      let url = TripfingerAppDelegate.serverUrl + "/download_country/\(region.getName())"
      var parameters = [String: String]()
      if TripfingerAppDelegate.mode != TripfingerAppDelegate.AppMode.RELEASE {
        parameters["fetchType"] = "STAGED_OR_PUBLISHED"
      } else {
        parameters["fetchType"] = "ONLY_PUBLISHED"
      }
      let jsonPath = countryPath.URLByAppendingPathComponent(region.getName() + ".json")
      if NSURL.fileExists(jsonPath) {
        processDownload(jsonPath, countryPath: countryPath, taskHandle: taskHandle, progressHandler: progressHandler, finishedHandler: finishedHandler)
      } else {
        NetworkUtil.saveDataFromUrl(url, destinationPath: jsonPath, parameters: parameters) {
          processDownload(jsonPath, countryPath: countryPath, taskHandle: taskHandle, progressHandler: progressHandler, finishedHandler: finishedHandler)
        }
      }
    }
  }
  
  private class func processDownload(jsonPath: NSURL, countryPath: NSURL, taskHandle: UIBackgroundTaskIdentifier, progressHandler: Double -> (), finishedHandler: () -> ()) {
    let jsonData = NSData(contentsOfURL: jsonPath)!
    let json = JSON(data: jsonData)
    let region = JsonParserService.parseRegionTreeFromJson(json)
    let imageList = fetchImageList(region, path: countryPath)
    var counter = 0.0
    splitImageListAndDownload(imageList, progressHandler: { requests in
      counter += 1
      dispatch_async(dispatch_get_main_queue()) {
        if DatabaseService.isDownloadMarkerCancelled(region.mwmRegionId ?? region.getName()) {
          for request in requests {
            request.cancel()
          }
          deleteCountry(region.getName())
          cleanupDownload(region, taskHandle: taskHandle, jsonPath: jsonPath)
          return
        }
        let progress = Double(counter / Double(imageList.count))
        progressHandler(progress)
      }
      }) {
        if DatabaseService.isDownloadMarkerCancelled(region.mwmRegionId ?? region.getName()) {
          return
        }
        print("Finished image downloads")
        try! DatabaseService.saveRegion(region) { _ in
          print("Persisted region to database")
          dispatch_async(dispatch_get_main_queue()) {
            progressHandler(1.0)
          }
          cleanupDownload(region, taskHandle: taskHandle, jsonPath: jsonPath)
          dispatch_async(dispatch_get_main_queue(), finishedHandler)
        }
    }
  }
  
  private class func cleanupDownload(region: Region, taskHandle: UIBackgroundTaskIdentifier, jsonPath: NSURL) {
    DatabaseService.removeDownloadMarker(region.mwmRegionId ?? region.getName())
    UIApplication.sharedApplication().idleTimerDisabled = false
    UIApplication.sharedApplication().endBackgroundTask(taskHandle)
    NSURL.deleteFile(jsonPath)
  }
  
  class func splitImageListAndDownload(imageList: [(String, NSURL)], progressHandler: ([Request]) -> (), finishedHandler: () -> ()) {
    var requestList = [Request]()
    let dispatchGroup = dispatch_group_create()
    for (url, destinationPath) in imageList {
      if NSURL.fileExists(destinationPath) {
        progressHandler(requestList)
        continue
      }
      let imageUrl = gcsImagesUrl + url
      let request = NetworkUtil.saveDataFromUrl(imageUrl, destinationPath: destinationPath, dispatchGroup: dispatchGroup) {
        progressHandler(requestList)
      }
      requestList.append(request)
    }
    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), finishedHandler)
  }
  
  class func fetchImageList(region: Region, path: NSURL) -> [(String, NSURL)] {
    var imageList = [(String, NSURL)]()
    imageList.appendContentsOf(fetchImageList(region.item(), path: path))
    
    for attraction in region.listings {
      imageList.appendContentsOf(fetchImageList(attraction.listing.item, path: path))
    }
    return imageList
  }
  
  class func getLocalPartOfFileUrl(fileUrl: NSURL) -> String {
    let pathIndex = fileUrl.absoluteString.rangeOfString("/Library/", options: .BackwardsSearch)
    return fileUrl.absoluteString.substringFromIndex(pathIndex!.endIndex)
  }
  
  class func fetchImageList(guideItem: GuideItem, path: NSURL) -> [(String, NSURL)] {
    var imageList = [(String, NSURL)]()
    for image in guideItem.images {
      let destinationPath = path.URLByAppendingPathComponent(image.url)
      imageList.append((image.url, destinationPath))
      image.url = getLocalPartOfFileUrl(destinationPath)
    }
    for guideSection in guideItem.guideSections {
      imageList.appendContentsOf(fetchImageList(guideSection.item, path: path))
    }
    for categoryDescription in guideItem.categoryDescriptions {
      imageList.appendContentsOf(fetchImageList(categoryDescription.item, path: path))
    }
    
    print("Fetching images in \(guideItem.name)'s \(guideItem.subRegions.count) sub regions")
    for subRegion in guideItem.subRegions {
      let subPath = NSURL.appendToDirectory(path, pathElement: subRegion.getName())
      imageList.appendContentsOf(fetchImageList(subRegion, path: subPath))
    }
    return imageList
  }
}