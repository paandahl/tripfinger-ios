import Foundation

extension NSBundle {
  
  class func bundlePathForIdentifier(identifier: String) -> String! {
    for bundle in NSBundle.allBundles() {
      if bundle.bundleIdentifier == "no.prebenludviksen.TripfingerTests" {
        return bundle.bundlePath
      }
    }
    return nil
  }
}