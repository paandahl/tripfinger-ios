import Foundation
import Alamofire
import RealmSwift

class DownloadService {
  
  static let tripfingerUrl = "http://tripfinger-server.appspot.com"
  static let gcsMapsUrl = "https://storage.googleapis.com/tripfinger-maps/"
  static let gcsImagesUrl = "https://storage.googleapis.com/tripfinger-maps/"
  
  class func downloadCity(countryId: String, cityId: String, progressHandler: Float -> ()) {
    
    let countryPath = NSURL.getDirectory(.LibraryDirectory, withPath: countryId)
    let cityPath = NSURL.getDirectory(.LibraryDirectory, withPath: countryId + "/" + cityId)
    
    var url = gcsMapsUrl + "BE.skm"
    var fileName = countryId + ".skm"
    var destinationPath = countryPath.URLByAppendingPathComponent(fileName)
    downloadFile(url, destinationPath: destinationPath, progressHandler: progressHandler)
    
    url = gcsMapsUrl + "BE.ngi"
    fileName = countryId + ".ngi"
    destinationPath = countryPath.URLByAppendingPathComponent(fileName)
    downloadFile(url, destinationPath: destinationPath, progressHandler: nil)
    
    url = gcsMapsUrl + "BE.ngi.dat"
    fileName = countryId + ".ngi.dat"
    destinationPath = countryPath.URLByAppendingPathComponent(fileName)
    downloadFile(url, destinationPath: destinationPath, progressHandler: nil)
    
    url = gcsMapsUrl + "BE.txg"
    fileName = countryId + ".txg"
    destinationPath = countryPath.URLByAppendingPathComponent(fileName)
    downloadFile(url, destinationPath: destinationPath, progressHandler: nil)
    
    Alamofire.request(.GET, tripfingerUrl + "/download_city/\(cityId)")
      .responseData { response in
        if response.result.isSuccess {
          
          let json = JSON(data: response.data!)
          let region = ContentService.parseRegionTreeFromJson(json)
          var imageList = getImageList(region.listing.item)
          imageList.appendContentsOf(getImageList(region))
          downloadImages(imageList, cityPath: cityPath)
          
          // Get the default Realm
          let realm = try! Realm()
          // You only need to do this once (per thread)
          
          // Add to the Realm inside a transaction
          try! realm.write {
            realm.add(region)
          }
        }
        else {
          print("ERROR: Downloading city JSON failed")
        }
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
  
  class func downloadImages(imageList: [GuideItemImage], cityPath: NSURL) {
    for image in imageList {
      Alamofire.request(.GET, image.url)
        .responseData { response in
          let index: String.Index = gcsImagesUrl.startIndex.advancedBy(gcsImagesUrl.characters.count)
          let fileName = image.url.substringFromIndex(index)
          print("Writing image to file: \(fileName)")
          let destinationPath = cityPath.URLByAppendingPathComponent(fileName)
          if response.result.isSuccess {
            let result = response.data?.writeToURL(destinationPath, atomically: true)
            if !result! {
              print("ERROR: Writing file failed")
            }
          }
          else {
            print("ERROR: Downloading image failed")
          }
      }
      
    }
  }
    
  class func downloadFile(url: String, destinationPath: NSURL, progressHandler: (Float -> ())?) {
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
        }
        else {
          print("ERROR: Downloading file failed")
        }
    }
  }
}