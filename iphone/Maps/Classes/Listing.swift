import Foundation
import RealmSwift

class Listing: Object {
  
  // composition (instead of inheritance - for Realm-purposes)
  dynamic var listing: GuideListing!
  
  dynamic var website: String?
  dynamic var email: String?
  dynamic var address: String?
  dynamic var phone: String?
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
    case ACCOMMODATION = 240
    case FOOD_OR_DRINK = 250
    case SHOPPING = 260
    case INFORMATION = 270
    
    static let entityMap = [
      "Attractions": ATTRACTIONS,
      "Transportation": TRANSPORTATION,
      "Accomodation": ACCOMMODATION,
      "Food and drinks": FOOD_OR_DRINK,
      "Shopping": SHOPPING,
      "Information": INFORMATION
    ]
    
    var entityName: String {
      switch self {
      case .ATTRACTIONS:
        return "Attractions"
      case .TRANSPORTATION:
        return "Transportation"
      case .ACCOMMODATION:
        return "Accommodation"
      case .FOOD_OR_DRINK:
        return "Food and drinks"
      case .SHOPPING:
        return "Shopping"
      case .INFORMATION:
        return "Information"
      }
    }
    
    static let allValues = [ATTRACTIONS, TRANSPORTATION, ACCOMMODATION,
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
    
    // ACCOMODATION
    case HOSTELS = 2400
    case GUESTHOUSES = 2410
    case HOTELS = 2420
    case APARTMENTS = 2430
    
    case CAFE = 2500//NIGHTLIFE, // CASINO_OR_GAMBLING
    case RESTAURANT = 2510
    case STREETFOOD = 2520
    case BAR = 2530
    case NIGHTCLUB = 2540
    
    // SHOPPING
    case MARKET = 2600
    case SHOPPING_CENTRE = 2610
    case SHOP = 2620
    // only for simplePois
    case SMALL_GROCERY = 2690
    case SUPERMARKET = 2691
    case BAKERY = 2692
    case ALCOHOL_SHOP = 2693
    case PHARMACY = 2694
    
    // INFORMATION & HEALTH
    case TOURIST_OFFICES = 2700
    case EMBASSIES = 2710 // TRAVELLER_RESOURCES,
    // only for SimplePois
    case HOSPITAL = 2790


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
      case .FERRY_STOP:
        return "Ferry stops"
      case .CAR_RENTAL:
        return "Car rentals"
      case .MOTORBIKE_RENTAL:
        return "Motorbike rentals"
      case .BICYCLE_RENTAL:
        return "Bicycle rentals"
      default:
        assertionFailure("entityName not set for category: \(self.rawValue)")
        return "Other"
      }
    }
    
    // 4172 - highway-bus_stop
    // 4305 - landuse-cemetery
    // 4498 - leisure-park
    // 268418 - amenity-place_of_worship-christian
    // 5762 - amentiy-hospital
    // 6210 - amenity-marketplace
    // 4674 - amenity-cafe
    // 6658 - amenity-restaurant
    // 5570 - amenity-fast_food
    // 7042 - amenity-theatre
    // 4226 - amenity-pub
    // 6274 - amenity-nightclub
    // 4771 - tourism-museum
    // 4259 - tourism-attraction
    // 4579 - tourism-hotel
    // 266787 - tourism-information-office
    // 4429 - historic-memorial
    // 4493 - historic-monument
    // 5985 - shop-mall
    // 97   - shop
    
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
        
      case .GUESTHOUSES:
        fallthrough
      case .HOSTELS:
        fallthrough
      case .APARTMENTS:
        fallthrough
      case .HOSTELS:
        return 4579 // tourism-hotel
        
      case .CAFE:
        return 4674 // amenity-cafe
      case .RESTAURANT:
        return 6658 // amenity-restaurant
      case .BAR:
        return 4226 // amenity-bar
      case .NIGHTCLUB:
        return 6274 // amenity-nightclub
      case .STREETFOOD:
        return 5570 // amenity-fast_food
        
      case .MARKET:
        return 6210 // amenity-marketplace
      case .SHOPPING_CENTRE:
        return 5985 // shop-mall
      case .SHOP:
        return 97 // shop

      case .TOURIST_OFFICES:
        return 266787 // tourism-information-office

      default:
        print("osmType not defined for category: \(self.rawValue)")
        return 4610 // amenity-bus_station
      }
    }

    
    static let allValues = [AIRPORT, TRAIN_STATION, BUS_STATION, FERRY_TERMINAL, CAR_RENTAL, MOTORBIKE_RENTAL, BICYCLE_RENTAL]
  }  

}
