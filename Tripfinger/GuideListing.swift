import Foundation
import RealmSwift

class GuideListing: Object {
  
  // composition (instead of inheritance - for Realm-purposes)
  dynamic var item: GuideItem!
    
  dynamic var longitude = 0.0
  dynamic var latitude = 0.0
  
  dynamic var continent: String!
  dynamic var country: String!
  dynamic var city: String!
  
  func getParentName() -> String {
    if city != nil {
      return city
    }
    else if country != nil {
      return country
    }
    else if continent != nil {
      return continent
    }
    else {
      return "Continents"
    }
  }
}