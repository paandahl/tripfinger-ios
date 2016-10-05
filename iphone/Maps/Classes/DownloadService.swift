import Foundation
import Alamofire
import RealmSwift
import BrightFutures
import SwiftyJSON
import Firebase

class DownloadService {
  
  static let TFDownloadStartedNotification = "TFDownloadStartedNotification"
  
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
    let path = NSURL.getImageDirectory().getSubDirectory(countryName)
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
  
  class func checkIfDeviceHasEnoughFreeSpaceForRegion(region: Region) -> Bool {
    let freeSpace = FileUtils.deviceRemainingFreeSpaceInBytes()
    let regionSize = region.getSizeInBytes()
    print("regionSize: \(regionSize)")
    if freeSpace < Int64(regionSize) {
      let alertController = UIAlertController(title: "Not enough disk space", message: "Free up space on your device by deleting something, and try again.", preferredStyle: .Alert)
      let defaultAction = UIAlertAction(title: "OK", style: .Default) { alertAction in
        TripfingerAppDelegate.navigationController.dismissViewControllerAnimated(true, completion: nil)
      }
      alertController.addAction(defaultAction)
      TripfingerAppDelegate.navigationController.presentViewController(alertController, animated: true, completion: nil)
      return false;
    } else {
      return true;
    }
  }
  
  class func downloadCountry(mwmRegionId: String, receipt: String? = nil, progressHandler: Double -> (), failure: () -> (), finishedHandler: () -> ()) {
    
    AnalyticsService.logDownloadCountry(mwmRegionId)
    
    DatabaseService.addDownloadMarker(mwmRegionId)
    let application = UIApplication.sharedApplication()
    application.idleTimerDisabled = true
    var taskHandle = UIBackgroundTaskInvalid
    taskHandle = application.beginBackgroundTaskWithExpirationHandler {
      application.endBackgroundTask(taskHandle)
      taskHandle = UIBackgroundTaskInvalid
    }
    dispatch_async(dispatch_get_main_queue()) {
      NSNotificationCenter.defaultCenter().postNotificationName(TFDownloadStartedNotification, object: mwmRegionId)      
    }

    ContentService.getCountryWithName(mwmRegionId, failure: failure) { region in
      
      let countryPath = NSURL.getImageDirectory().getSubDirectory(region.getName())
      let jsonPath = countryPath.URLByAppendingPathComponent(region.getName() + ".json")
      if (!checkIfDeviceHasEnoughFreeSpaceForRegion(region)) {
        cleanupDownload(region, taskHandle: taskHandle, jsonPath: jsonPath!)
        finishedHandler()
        return
      }
      
      var url: String
      if let _ = receipt {
        url = TripfingerAppDelegate.serverUrl + "/download_purchased_country/\(region.getName())"
      } else {
        let deviceUuid = UniqueIdentifierService.uniqueIdentifier()
        url = TripfingerAppDelegate.serverUrl + "/download_first_country/\(region.getName())/\(deviceUuid)"
      }
      if NSURL.fileExists(jsonPath!) {
        processDownload(jsonPath!, countryPath: countryPath, taskHandle: taskHandle, progressHandler: progressHandler, failure: failure, finishedHandler: finishedHandler)
      } else {
        var method = Alamofire.Method.GET
        if receipt != nil {
          method = .POST
        }

        NetworkUtil.saveDataFromUrl(url, destinationPath: jsonPath!, method: method, body: receipt, failure: failure) {
          processDownload(jsonPath!, countryPath: countryPath, taskHandle: taskHandle, progressHandler: progressHandler, failure: failure, finishedHandler: finishedHandler)
        }
      }
    }
  }
  
  private class func processDownload(jsonPath: NSURL, countryPath: NSURL, taskHandle: UIBackgroundTaskIdentifier, progressHandler: Double -> (), failure: () -> (), finishedHandler: () -> ()) {
    let jsonData = NSData(contentsOfURL: jsonPath)!
    let json = JSON(data: jsonData)
    let region = JsonParserService.parseRegionTreeFromJson(json)
    let imageList = fetchImageList(region, path: countryPath)
    var counter = 0.0
    splitImageListAndDownload(imageList, progressHandler: { requests in
      counter += 1
      SyncManager.syncMain {
        if DatabaseService.isDownloadMarkerCancelled(region.mwmRegionId ?? region.getName()) {
          requests.forEach { $0.cancel() }
          deleteCountry(region.getName())
          cleanupDownload(region, taskHandle: taskHandle, jsonPath: jsonPath)
          return
        }
        let progress = Double(counter / Double(imageList.count))
        progressHandler(progress)
      }
    }, failure: failure) {
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
  
  class func splitImageListAndDownload(imageList: [(String, NSURL)], progressHandler: ([Request]) -> (), failure: () -> (), finishedHandler: () -> ()) {
    var requestList = [Request]()
    let dispatchGroup = dispatch_group_create()
    for (url, destinationPath) in imageList {
      if NSURL.fileExists(destinationPath) {
        progressHandler(requestList)
        continue
      }
      let imageUrl = gcsImagesUrl + url
      let request = NetworkUtil.saveDataFromUrl(imageUrl, destinationPath: destinationPath, dispatchGroup: dispatchGroup, failure: failure) {
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
    let pathIndex = fileUrl.absoluteString!.rangeOfString("Images/", options: .BackwardsSearch)
    return fileUrl.absoluteString!.substringFromIndex(pathIndex!.endIndex)
  }
  
  class func fetchImageList(guideItem: GuideItem, path: NSURL) -> [(String, NSURL)] {
    var imageList = [(String, NSURL)]()
    for image in guideItem.images {
      let destinationPath = path.URLByAppendingPathComponent(image.url)
      imageList.append((image.url, destinationPath!))
      image.url = getLocalPartOfFileUrl(destinationPath!)
    }
    for guideSection in guideItem.guideSections {
      imageList.appendContentsOf(fetchImageList(guideSection.item, path: path))
    }
    for categoryDescription in guideItem.categoryDescriptions {
      imageList.appendContentsOf(fetchImageList(categoryDescription.item, path: path))
    }
    
    print("Fetching images in \(guideItem.name)'s \(guideItem.subRegions.count) sub regions")
    for subRegion in guideItem.subRegions {
      let subPath = path.getSubDirectory(subRegion.getName())
      imageList.appendContentsOf(fetchImageList(subRegion, path: subPath))
    }
    return imageList
  }
}
