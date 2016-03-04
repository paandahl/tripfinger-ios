import Foundation
import RealmSwift

class Attraction: Object {
  
  // composition (instead of inheritance - for Realm-purposes)
  dynamic var listing: GuideListing!
  
  dynamic var price: String?
  dynamic var openingHours: String?
  dynamic var directions: String?
  
  func categoryName() -> String {
    return Category(rawValue: listing.item.category)!.entityName
  }
  
  func item() -> GuideItem {
    return listing.item
  }
  
  enum Category: Int {
    case ATTRACTIONS = 210
//    case EXPLORE_CITY = 210
//    case ACTIVITY_HIKE_DAYTRIP = 220
    case TRANSPORTATION = 230
    case ACCOMODATION = 240
    case FOOD_OR_DRINK = 250
    case SHOPPING = 260
    case INFORMATION = 270
    
    var entityName: String {
      switch self {
      case .ATTRACTIONS:
        return "Attractions"
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
    
    static let allValues = [ATTRACTIONS, TRANSPORTATION, ACCOMODATION,
      FOOD_OR_DRINK, SHOPPING, INFORMATION]
  }
  
  enum SubCategory: Int {

    // ATTRACTIONS
    case SIGHTS_AND_LANDMARKS = 2100
    case TOUR = 2110
    case MUSEUM = 2120
    case PARK = 2130
    case HOOD = 2140
    case NATURE = 2145
    case DAYTRIPS = 2150
    case SPORTS = 2155
    case AMUSEMENT_PARK = 2160
    case FUN_AND_GAMES = 2165
    case CLASS_OR_WORKSHOP = 2170
    case SPA_OR_WELLNESS = 2175
    case THEATER_AND_CONCERTS = 2180
    case FESTIVALS = 2185    

    // TRANSPORT
    case AIRPORT = 2300
    case TRAIN_STATION = 2310
    case BUS_STATION = 2320
    case FERRY_TERMINAL = 2330
    case CAR_RENTAL = 2340
    case MOTORBIKE_RENTAL = 2350
    case BICYCLE_RENTAL = 2360
    
    case BUS_STOP = 2390
    case FERRY_STOP = 2391
    case METRO_STATION = 2392
    case METRO_ENTRANCE = 2393
    case TRAM_STOP = 2394

    var entityName: String {
      switch self {
      case .AIRPORT:
        return "Airports"
      case .TRAIN_STATION:
        return "Train stations"
      case .BUS_STATION:
        return "Bus stations"
      case .FERRY_TERMINAL:
        return "Ferry terminals"
      case .CAR_RENTAL:
        return "Car rentals"
      case .MOTORBIKE_RENTAL:
        return "Motorbike rentals"
      case .BICYCLE_RENTAL:
        return "Bicycle rentals"
      default:
        fatalError("entityName not set for category: \(self.rawValue)")
      }
    }
    
    static let allValues = [AIRPORT, TRAIN_STATION, BUS_STATION, FERRY_TERMINAL, CAR_RENTAL, MOTORBIKE_RENTAL, BICYCLE_RENTAL]
  }  

}
