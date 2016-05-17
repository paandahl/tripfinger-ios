import Foundation

extension NSURL {
  class func getDirectory(baseDir: NSSearchPathDirectory, withPath path: String) -> NSURL {
    let libraryPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(baseDir, .UserDomainMask, true)[0])
    return libraryPath.URLByAppendingPathComponent(path)
  }

  class func createDirectory(baseDir: NSSearchPathDirectory, withPath path: String) -> NSURL {
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
      fatalError("Ooops! Something went wrong: \(error)")
    }
  }
  
  class func appendToDirectory(baseDir: NSURL, pathElement: String) -> NSURL {
    let folderPath = baseDir.URLByAppendingPathComponent(pathElement)
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