import Foundation
import RealmSwift

class GuideItemImage: Object {
  dynamic var url: String!
  dynamic var imageDescription: String!
  
  func getFileUrl() -> NSURL {
    return NSURL.getDirectory(.LibraryDirectory, withPath: url)
  }
}
