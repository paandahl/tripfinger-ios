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
  
  // temporary data to make life easier
  var mapCountry = false
  var mapPackage: SKTPackage!
  var offline = false;
  
  override static func ignoredProperties() -> [String] {
    return ["offline", "mapCountry", "mapPackage"]
  }
  
  func item() -> GuideItem {
    return listing.item
  }
  
  class func constructRegion(name: String, parent: Region) -> Region {
    let continent = parent.listing.continent != nil ? parent.listing.continent : parent.item().name
    var country: String! = nil
    if parent.item().category > Category.CONTINENT.rawValue {
      country = parent.listing.country != nil ? parent.listing.country : parent.item().name
    }
    var city: String! = nil
    if parent.item().category > Category.COUNTRY.rawValue {
      city = parent.listing.city != nil ? parent.listing.city : parent.item().name
    }
    return constructRegion(name, continent: continent, country: country, city: city)
  }
  
  class func constructRegion(name: String! = nil, continent: String! = nil, country: String! = nil, city: String! = nil, fromSearchResult: Bool = false) -> Region {
    let region = Region()
    region.listing = GuideListing()
    region.listing.item = GuideItem()
    region.listing.item.name = name
    region.listing.item.contentLoaded = false
    region.item().category = fromSearchResult ? 0 : Category.CONTINENT.rawValue
    if continent != nil {
      region.listing.continent = continent
      region.item().category = Category.COUNTRY.rawValue
    }
    if country != nil {
      region.listing.country = country
      region.item().category = Category.CITY.rawValue
    }
    if city != nil {
      region.listing.city = city
      region.item().category = Category.NEIGHBOURHOOD.rawValue
    }
    return region
  }
  
}

extension Region: GuideItemHolder {
  
  func getId() -> String {
    return listing.item.id
  }
  
  func getName() -> String {
    return listing.item.name!
  }
}
