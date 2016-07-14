import Foundation
import FirebaseCrash

class LogUtils {
  
  class func assertionFailAndRemoteLogException(exception: NSError, message: String) {
    assertionFailure(message)
    FIRCrashMessage(message)
    FIRCrashMessage(exception.description)
  }
  
  class func assertionFailAndRemoteLog(message: String) {
    assertionFailure(message)
    FIRCrashMessage(message)    
  }
}