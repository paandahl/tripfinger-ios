import Foundation
import Alamofire

class DownloadService {
  
  static let tripfingerUrl = "http://tripfinger-server.appspot.com"
  static let gcsMapsUrl = "https://storage.googleapis.com/tripfinger-maps/"
  static let gcsImagesUrl = "https://storage.googleapis.com/tripfinger-maps/"
  
  class func downloadCity(countryId: String, cityId: String, progressHandler: Float -> ()) {
    
    let countryPath = getDirectory(.LibraryDirectory, withPath: countryId)
    let cityPath = getDirectory(.LibraryDirectory, withPath: countryId + "/" + cityId)
    
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
          let imageList = getImageList(region)
          downloadImages(imageList, cityPath: cityPath)
        }
        else {
          print("ERROR: Downloading city JSON failed")
        }
    }
  }
  
  class func getImageList(guideItem: GuideItem) -> [GuideItemImage] {
    var imageList = [GuideItemImage]()
    for image in guideItem.images {
      imageList.append(image)
    }
    for guideSection in guideItem.guideSections {
      imageList.appendContentsOf(getImageList(guideSection))
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
  
  class func getDirectory(baseDir: NSSearchPathDirectory, withPath path: String) -> NSURL {
    let libraryPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(baseDir, .UserDomainMask, true)[0])
    let folderPath = libraryPath.URLByAppendingPathComponent(path)
    do {
      try NSFileManager.defaultManager().createDirectoryAtPath(folderPath.path!, withIntermediateDirectories: true, attributes: nil)
    } catch let error as NSError {
      NSLog("Unable to create directory \(error.debugDescription)")
    }
    return folderPath
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