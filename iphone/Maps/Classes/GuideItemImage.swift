import Foundation
import RealmSwift

class GuideItemImage: Object {
  dynamic var url: String!
  dynamic var imageDescription: String!
  dynamic var license: String!
  dynamic var artist: String!
  dynamic var originalUrl: String!
  
  func getFileUrl() -> NSURL {
    print("constructing file url: \(url)")
    return NSURL(string: url, relativeToURL: NSURL.getDirectory(.LibraryDirectory, withPath: "/"))!
  }
}
