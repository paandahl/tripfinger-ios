import Foundation
import RealmSwift

class GuideItem: Object {
  
  dynamic var id: String!
  dynamic var slug: String?
  dynamic var name: String?
  dynamic var price = 0.0
  dynamic var category = 0
  
  dynamic var parent: String!
  dynamic var content: String?
  dynamic var openingHours: String?
  
  let images = List<GuideItemImage>()
  
  // temporary data to make things easier
  var guideSections = List<GuideText>()
  var categoryDescriptions = List<GuideText>()
}
