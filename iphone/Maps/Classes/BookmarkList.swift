import Foundation

class BookmarkList {
  
  private static let PROPERTY_NAME = "name"

  let name: String
  
  init(name: String) {
    self.name = name
  }
  
  init(dict: [String: AnyObject]) {
    self.name = dict[BookmarkList.PROPERTY_NAME] as! String
  }
  
  func toDict() -> [String: AnyObject] {
    var dict = [String: AnyObject]()
    dict[BookmarkList.PROPERTY_NAME] = name
    return dict
  }
}