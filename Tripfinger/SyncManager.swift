//
//  SyncManager.swift
//  Tripfinger
//
//  Created by Preben Ludviksen on 20/10/15.
//  Copyright © 2015 Preben Ludviksen. All rights reserved.
//

import Foundation

class SyncManager {
  
  class func synced(lock: AnyObject, closure: () -> ()) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
  }
  
  class func run_async(closure: () -> ()) {
    let qualityOfServiceClass = QOS_CLASS_BACKGROUND
    let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
    dispatch_async(backgroundQueue, {
      closure()
    })
  }
}