import Foundation
import KeychainSwift

class UniqueIdentifierService {
  
  static let key = "tfUniqueId"
  
  class func uniqueIdentifier() -> String {
    let keychain = KeychainSwift()
    var id = keychain.get(key)
    if id == nil {
      id = NSUUID().UUIDString
      keychain.set(id!, forKey: key)
    }
    return id!
  }  
}