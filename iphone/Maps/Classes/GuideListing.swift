import Foundation
import RealmSwift

class GuideListing: Object {
  
  // composition (instead of inheritance - for Realm-purposes)
  dynamic var item: GuideItem!
    
  dynamic var longitude = 0.0
  dynamic var latitude = 0.0
  
  dynamic var continent: String? = nil
  dynamic var worldArea: String? = nil
  dynamic var country: String? = nil
  dynamic var region: String? = nil
  dynamic var subRegion: String? = nil
  dynamic var city: String? = nil
  
  dynamic var notes: GuideListingNotes?

  func getParentName() -> String {
    if let city = city {
      return city
    }
    else if let subRegion = subRegion {
      return subRegion
    }
    else if let country = country {
      return country
    }
    else {
      return "Overview"
    }
  }
}