import Foundation
import RealmSwift

protocol GuideItemHolder: class {
  func getId() -> String!
  func getName() -> String
}

class GuideItem: Object {
  
  dynamic var versionId: String!
  dynamic var uuid: String!
  dynamic var slug: String?
  dynamic var name: String!
  dynamic var category = 0
  dynamic var subCategory = 0
  dynamic var status = 0
  
  dynamic var parent: String!
  dynamic var content: String?
  dynamic var textLicense: String?
    
  var images = List<GuideItemImage>()
  var guideSections = List<GuideText>()
  var subRegions = List<Region>()
  var categoryDescriptions = List<GuideText>()
  
  func getSubRegions() -> [Region] {
    let subs = Array(subRegions)
    return subs.sort { a, b in a.getName() < b.getName() }
  }
  
  var allCategoryDescriptions: [GuideText] {
    get {
      var catDescs = [GuideText]()
      for categoryDescription in categoryDescriptions {
        categoryDescription.item.loadStatus = GuideItem.LoadStatus.CHILDREN_NOT_LOADED
        catDescs.append(categoryDescription)
      }
      return catDescs
    }
  }

  // temporary data to make things easier
  var loadStatus = LoadStatus.FULLY_LOADED
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
