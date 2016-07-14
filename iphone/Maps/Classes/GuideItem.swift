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
  
  var allCategoryDescriptions: List<GuideText> {
    get {
      let allCategoryDescriptions = List<GuideText>()
      var categoryDescriptionsDict = Dictionary<Int, GuideText>()
      for categoryDescription in categoryDescriptions {
        categoryDescriptionsDict[categoryDescription.item.category] = categoryDescription
      }
      print("region \(name) had \(allCategoryDescriptions.count) category sections.")
      
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
          categoryDescription!.item.offline = offline
          categoryDescription!.item.loadStatus = GuideItem.LoadStatus.FULLY_LOADED
          allCategoryDescriptions.append(categoryDescription!)
        }
      }
      return allCategoryDescriptions
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
