//
//  NSURL+GetDirectory.swift
//  Tripfinger
//
//  Created by Preben Ludviksen on 19/11/15.
//  Copyright © 2015 Preben Ludviksen. All rights reserved.
//

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