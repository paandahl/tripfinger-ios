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
    case ATTRACTIONS = 200
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
    // TRANSPORT
    case AIRPORT = 2300
    case TRAIN_STATION = 2310
    case BUS_STATION = 2320
    case FERRY_TERMINAL = 2330
    case CAR_RENTAL = 2340
    case MOTORBIKE_RENTAL = 2350
    case BICYCLE_RENTAL = 2360

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
      }
    }
    
    static let allValues = [AIRPORT, TRAIN_STATION, BUS_STATION, FERRY_TERMINAL, CAR_RENTAL, MOTORBIKE_RENTAL, BICYCLE_RENTAL]
  }  

}
