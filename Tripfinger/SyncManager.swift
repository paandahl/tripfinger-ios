import Foundation

class SyncManager {
  
  class func synchronized(lock: AnyObject, closure: () -> ()) {
    get_lock(lock)
    closure()
    try! release_lock(lock)
  }
  
  class func synchronized_async(lockQueue: dispatch_queue_t, closure: () -> ()) {
    run_async {
      synchronized(lockQueue, closure: closure)
    }
  }
  
  class func block_until_condition(lock: AnyObject, condition: () -> Bool, after: () -> ()) {
    var conditionMet = false
    while true {
      synchronized(lock) {
        conditionMet = condition()
        if conditionMet {
          after()
        }
      }      
      if conditionMet {
        break
      }
      else {
        usleep(10 * 1000)
      }
    }
  }
  
  /*
  * The lock must be released in the same thread as it's locked on.
  */
  
  class func get_lock(lock: AnyObject) {
    objc_sync_enter(lock)
  }
  
  class func release_lock(lock: AnyObject) throws {
    let result = objc_sync_exit(lock)
    switch Int(result) {
    case OBJC_SYNC_SUCCESS:
      break
    default:
      print("release result: \(result)")
      throw Error.RuntimeError("Tried to release lock held by another thread.")
    }
  }
  
  class func run_async(closure: () -> ()) {
    let qualityOfServiceClass = QOS_CLASS_BACKGROUND
    let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
    dispatch_async(backgroundQueue, {
      closure()
    })
  }
}