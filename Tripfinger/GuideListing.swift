import Foundation
import RealmSwift

class GuideListing: Object {
  
  // composition (instead of inheritance - for Realm-purposes)
  dynamic var item: GuideItem!
    
  dynamic var longitude = 0.0
  dynamic var latitude = 0.0
  
  dynamic var continent: String!
  dynamic var worldArea: String!
  dynamic var country: String!
  dynamic var region: String!
  dynamic var subRegion: String!
  dynamic var city: String!
  
  dynamic var notes: GuideListingNotes?

  func getParentName() -> String {
    if city != nil {
      return city
    }
    else if subRegion != nil {
      return subRegion
    }
    else if country != nil {
      return country
    }
    else {
      return "Overview"
    }
  }
}