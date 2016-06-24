import Foundation
import KeychainSwift

class UniqueIdentifierService {
  
  static let key = "tfUniqueId"
  static var testId: String?
  
  class func uniqueIdentifier() -> String {
    if TripfingerAppDelegate.mode == TripfingerAppDelegate.AppMode.TEST {
      if let testId = testId {
        return testId
      } else {
        testId = "test" + NSUUID().UUIDString
        return testId!
      }
    }
    let keychain = KeychainSwift()
    var id = keychain.get(key)
    if keychain.lastResultCode != noErr && keychain.lastResultCode != errSecItemNotFound {
      fatalError("keychain returned error: \(keychain.lastResultCode)")
    }
    if id == nil {
      id = NSUUID().UUIDString
      keychain.set(id!, forKey: key)
    }
    return id!
  }  
}