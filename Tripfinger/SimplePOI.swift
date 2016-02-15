import Foundation
import RealmSwift

class SimplePOI: Object {

  convenience init(listing: GuideListing) {
    self.init()
    name = listing.item.name
    category = listing.item.category
    location = listing.country
    if listing.city != nil {
      location = location + ", \(listing.city)"
    }
    
    latitude = listing.latitude
    longitude = listing.longitude
    listingId = listing.item.id
    notes = listing.notes
  }

  dynamic var name: String!
  dynamic var category = 0
  dynamic var location: String!
  dynamic var latitude = 0.0
  dynamic var longitude = 0.0
  var listingId: String!
  
  func isRealAttraction() -> Bool {
    return listingId != nil && listingId != "simple"
  }
  
  // temporary variable connecting SimplePOI-representations of real Attractions to AttractionSwipe
  var notes: GuideListingNotes!
  
  // temporary variables for skobbler search code
  var offlinePackageCode: String!
  var identifier: UInt64!
  
  override static func ignoredProperties() -> [String] {
    return ["swipe", "offlinePackageCode", "identifier"]
  }

}