import Foundation
import RealmSwift

class Attraction: Object {
  
  // composition (instead of inheritance - for Realm-purposes)
  dynamic var listing: GuideListing!
  
  func getImagePath(currentRegion: Region) -> NSURL? {
    var imagePath: NSURL? = nil
    if currentRegion.offline {
      let countryId = currentRegion.listing.item.parent
      let cityId = currentRegion.listing.item.id
      let cityPath = NSURL.getDirectory(.LibraryDirectory, withPath: countryId + "/" + cityId)
      imagePath = cityPath.URLByAppendingPathComponent(listing.item.id + "-1")
    }
    return imagePath
  }
  
  func categoryName(currentRegion: Region?) -> String {
    let name = Category(rawValue: listing.item.category)!.entityName
    if name == "Explore the city" {
      if currentRegion == nil {
        return "Explore the world"
      }
      switch currentRegion!.listing.item.category {
      case Region.Category.COUNTRY.rawValue:
        return "Explore the country"
      default:
        return name
      }
    }
    return name
  }
  
  enum Category: Int {
    case ALL = 200
    case EXPLORE_CITY = 210
    case ACTIVITY_HIKE_DAYTRIP = 220
    case TRANSPORTATION = 230
    case ACCOMODATION = 240
    case FOOD_OR_DRINK = 250
    case SHOPPING = 260
    case INFORMATION = 270
    
    var entityName: String {
      switch self {
      case .ALL:
        return "All listings"
      case .EXPLORE_CITY:
        return "Explore the city"
      case .ACTIVITY_HIKE_DAYTRIP:
        return "Activities"
      case .TRANSPORTATION:
        return "Transportation"
      case .ACCOMODATION:
        return "Accomodation"
      case .FOOD_OR_DRINK:
        return "Food and drinks"
      case .SHOPPING:
        return "Shopping"
      case .INFORMATION:
        return "Information"
      }
    }
    
    func entityName(currentRegion: Region?) -> String {
      if entityName == "Explore the city" {
        if currentRegion == nil {
          return "Explore the world"
        }
        switch currentRegion!.listing.item.category {
        case Region.Category.COUNTRY.rawValue:
          return "Explore the country"
        default:
          return entityName
        }
      }
      return entityName
    }
    
    static let allValues = [ALL, EXPLORE_CITY, ACTIVITY_HIKE_DAYTRIP, TRANSPORTATION, ACCOMODATION,
      FOOD_OR_DRINK, SHOPPING, INFORMATION]
  }
  
  // Temprorary data for swiper
  var swipedRight: Bool!
}
