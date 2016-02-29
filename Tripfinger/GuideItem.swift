import Foundation
import RealmSwift

protocol GuideItemHolder: class {
  func getId() -> String
  func getName() -> String
}

class GuideItem: Object {
  
  dynamic var id: String!
  dynamic var slug: String?
  dynamic var name: String!
  dynamic var category = 0
  dynamic var subCategory = 0
  dynamic var status = 0
  
  dynamic var parent: String!
  dynamic var content: String?
  dynamic var openingHours: String?
    
  let images = List<GuideItemImage>()
  
  var guideSections = List<GuideText>()
  var subRegions = List<Region>()
  var simplePois = List<SimplePOI>()
  var categoryDescriptions = List<GuideText>()

  // temporary data to make things easier
  var loadStatus = LoadStatus.CONTENT_NOT_LOADED
  var offline = true
  
  enum LoadStatus {
    case CONTENT_NOT_LOADED // only name and category is set
    case CHILDREN_NOT_LOADED
    case FULLY_LOADED
  }

  override static func ignoredProperties() -> [String] {
    return ["loadStatus", "offline"]
  }
}
