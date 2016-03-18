import Foundation
import RealmSwift

protocol GuideItemHolder: class {
  func getId() -> String
  func getName() -> String
}

class GuideItem: Object {
  
  dynamic var id: String!
  dynamic var uuid: String!
  dynamic var slug: String?
  dynamic var name: String!
  dynamic var category = 0
  dynamic var subCategory = 0
  dynamic var status = 0
  
  dynamic var parent: String!
  dynamic var content: String?
  dynamic var openingHours: String?
  dynamic var textLicense: String?
    
  let images = List<GuideItemImage>()
  
  var guideSections = List<GuideText>()
  var subRegions = List<Region>()
  var simplePois = List<SimplePOI>()
  var categoryDescriptions = List<GuideText>()
  
  var allCategoryDescriptions: List<GuideText> {
    get {
      let allCategoryDescriptions = List<GuideText>()
      var categoryDescriptionsDict = Dictionary<Int, GuideText>()
      for categoryDescription in categoryDescriptions {
        categoryDescriptionsDict[categoryDescription.item.category] = categoryDescription
      }
      
      for category in Listing.Category.allValues {
        var categoryDescription = categoryDescriptionsDict[category.rawValue]
        if let categoryDescription = categoryDescription {
          categoryDescription.item.loadStatus = GuideItem.LoadStatus.CHILDREN_NOT_LOADED
          allCategoryDescriptions.append(categoryDescription)
        } else {
          categoryDescription = GuideText()
          categoryDescription!.item = GuideItem()
          categoryDescription!.item.category = category.rawValue
          categoryDescription!.item.name = category.entityName
          categoryDescription!.item.content = nil
          categoryDescription!.item.loadStatus = GuideItem.LoadStatus.FULLY_LOADED
          allCategoryDescriptions.append(categoryDescription!)
        }
      }
      return allCategoryDescriptions
    }
  }

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
