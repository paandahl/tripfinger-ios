import Foundation
import FirebaseCrash

class FileUtils {
  class func deviceRemainingFreeSpaceInBytes() -> Int64 {
    let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    var attributes: [String: AnyObject]
    do {
      attributes = try NSFileManager.defaultManager().attributesOfFileSystemForPath(documentDirectoryPath.last! as String)
      let freeSize = attributes[NSFileSystemFreeSize] as! NSNumber
      return freeSize.longLongValue
    } catch let error as NSError {
      LogUtils.assertionFailAndRemoteLogException(error, message: "Could not measure free disk space.")
      return 1000 * 1000 * 1000
    }
  }
}

extension NSURL {
  
  class func getImageDirectory() -> NSURL {
    let url = createDirectory(.ApplicationSupportDirectory, withPath: "Images")
    do {
      try url.setResourceValue(true, forKey: NSURLIsExcludedFromBackupKey)
    } catch let error as NSError {
      LogUtils.assertionFailAndRemoteLogException(error, message: "Error excluding image directory from backup")
    }
    return url
  }
  
  private class func getDirectory(baseDir: NSSearchPathDirectory, withPath path: String? = nil) -> NSURL {
    let libraryPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(baseDir, .UserDomainMask, true)[0])
    if let path = path {
      return libraryPath.URLByAppendingPathComponent(path)
    } else {
      return libraryPath
    }
  }

  private class func createDirectory(baseDir: NSSearchPathDirectory, withPath path: String) -> NSURL {
    let folderPath = getDirectory(baseDir, withPath: path)
    do {
      try NSFileManager.defaultManager().createDirectoryAtPath(folderPath.path!, withIntermediateDirectories: true, attributes: nil)
    } catch let error as NSError {
      NSLog("Unable to create directory \(error.debugDescription)")
    }
    return folderPath
  }
  
  class func fileExists(baseDir: NSSearchPathDirectory, withPath path: String) -> Bool {
    let folderPath = getDirectory(baseDir, withPath: path)
    return NSFileManager.defaultManager().fileExistsAtPath(folderPath.path!)
  }

  class func fileExists(url: NSURL) -> Bool {
    return NSFileManager.defaultManager().fileExistsAtPath(url.path!)
  }

  class func deleteFile(url: NSURL) {
    do {
      try NSFileManager.defaultManager().removeItemAtURL(url)
    } catch _ {}
  }
  
  class func moveFile(sourceDir: NSURL, destinationDir: NSURL) {
    let fileManager = NSFileManager.defaultManager()    
    do {
      try fileManager.moveItemAtPath(sourceDir.path!, toPath: destinationDir.path!)
    }
    catch let error as NSError {
      fatalError("Something went wrong when moving file: \(error)")
    }
  }
  
  func getSubDirectory(pathElement: String) -> NSURL {
    let folderPath = self.URLByAppendingPathComponent(pathElement)
    do {
      try NSFileManager.defaultManager().createDirectoryAtPath(folderPath.path!, withIntermediateDirectories: true, attributes: nil)
    } catch let error as NSError {
      NSLog("Unable to create directory \(error.debugDescription)")
    }
    return folderPath
  }
  
  class func deleteFolder(path: NSURL) {
    do {
      try NSFileManager.defaultManager().removeItemAtURL(path)
    } catch let error as NSError {
      NSLog("Unable to delete directory \(error.debugDescription)")
    }
  }
}