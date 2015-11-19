import Foundation
import RealmSwift

class Region: Object {
  
  // composition (instead of inheritance - for Realm-purposes)
  dynamic var listing: GuideListing!
  
  // radius
  var radius: Int?
  
  // polygons
//  var polygonCoordinates: [Double]?
  
  let attractions = List<Attraction>()
  
  func setCategory(category: Region.Category) {
    listing.item.category = category.rawValue
  }
  
  enum Category: Int {
    case CONTINENT = 110
    case WORLD_AREA = 120
    case COUNTRY = 130
    case REGION = 140
    case SUB_REGION = 150
    case CITY = 160
    case NEIGHBOURHOOD = 170
  }
  
  var offline = false;
  
  override static func ignoredProperties() -> [String] {
    return ["offline"]
  }
}

