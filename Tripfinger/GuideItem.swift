import Foundation
import RealmSwift

class GuideItem: Object {
  
  var id: String!
  var slug: String?
  var name: String?
  var price: Double?
  var category: Int?
  
  var parent: GuideItem?
  var content: String?
  var openingHours: String?
  
  var images = List<GuideItemImage>()
  
  // temporary data to make things easier
  var guideSections = List<GuideText>()
  var categoryDescriptions = List<GuideText>()
}
