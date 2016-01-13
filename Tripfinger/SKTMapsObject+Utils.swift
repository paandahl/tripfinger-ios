import Foundation

extension SKTMapsObject {
  func getMapPackage(name: String, type: SKTPackageType) -> SKTPackage! {
    let packagesOfType = packagesForType(type) as! [SKTPackage]
    for packageOfType in packagesOfType {
      if packageOfType.nameForLanguageCode("en") == name {
        return packageOfType
      }
    }
    return nil
  }
}
