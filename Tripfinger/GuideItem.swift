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
  dynamic var price = 0.0
  dynamic var category = 0
  
  dynamic var parent: String!
  dynamic var content: String?
  dynamic var openingHours: String?
  var contentLoaded = true
    
  let images = List<GuideItemImage>()
  
  // temporary data to make things easier
  var guideSections = List<GuideText>()
  var subRegions = List<Region>()
  var categoryDescriptions = List<GuideText>()
  
  override static func ignoredProperties() -> [String] {
    return ["contentLoaded"]
  }

}