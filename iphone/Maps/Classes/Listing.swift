import Foundation
import RealmSwift

class Listing: Object {
  
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
      case .METRO_STATION:
        return "Metro stations"
      case .TRAM_STOP:
        return "Tram stations"
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
    
    // 4172 - highway-bus_stop
    // 4305 - landuse-cemetery
    // 4498 - leisure-park
    // 268418 - amenity-place_of_worship-christian
    // 5762 - amentiy-hospital
    // 4674 - amenity-cafe
    // 6658 - amenity-restaurant
    // 7042 - amenity-theatre
    // 4771 - tourism-museum
    // 4259 - tourism-attraction
    // 4429 - historic-memorial
    // 4493 - historic-monument
    var osmType: Int {
      switch self {
      case .SIGHTS_AND_LANDMARKS:
        return 4259 // tourism-attraction
      case .TOUR:
        return 4259 // tourism-attraction
      case .MUSEUM:
        return 4771 // tourism-museum
      case .PARK:
        return 4498 // leisure-park
      case .HOOD:
        return 4259 // tourism-attraction
      case .NATURE:
        return 4498 // leisure-park
      case .DAYTRIPS:
        return 4259 // tourism-attraction
      case .SPORTS:
        return 4259 // tourism-attraction
      case .AMUSEMENT_PARK:
        return 4259 // tourism-attraction
      case .FUN_AND_GAMES:
        return 4259 // tourism-attraction
      case .CLASS_OR_WORKSHOP:
        return 4259 // tourism-attraction
      case .SPA_OR_WELLNESS:
        return 4259 // tourism-attraction
      case .THEATER_AND_CONCERTS:
        return 7042 // amenity-theatre
      case .FESTIVALS:
        return 4259 // tourism-attraction

      case .AIRPORT:
        return 4097 // aeroway-aerodrome
      case .TRAIN_STATION:
        return 5279 // railway-station
      case .BUS_STATION:
        return 4610 // amenity-bus_station
      case .METRO_STATION:
        return 271519 // railway-station-subway
      case .TRAM_STOP:
        return 4610 // amenity-bus_station
      case .FERRY_TERMINAL:
        return 4610 // amenity-bus_station
      case .CAR_RENTAL:
        return 4610 // amenity-bus_station
      case .MOTORBIKE_RENTAL:
        return 4610 // amenity-bus_station
      case .BICYCLE_RENTAL:
        return 4610 // amenity-bus_station
      default:
        print("osmType not defined for category: \(self.rawValue)")
        return 4610 // amenity-bus_station
//        fatalError("osmType not defined for category: \(self.rawValue)")
      }
    }

    
    static let allValues = [AIRPORT, TRAIN_STATION, BUS_STATION, FERRY_TERMINAL, CAR_RENTAL, MOTORBIKE_RENTAL, BICYCLE_RENTAL]
  }  

}
