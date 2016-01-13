import Foundation
import RealmSwift

class SimplePOI: Object {
  
  required init() {
    super.init()
  }

  init(listing: GuideListing) {
    super.init()
    name = listing.item.name
    category = listing.item.category
    location = listing.country
    if listing.city != nil {
      location = location + ", \(listing.city)"
    }
    coordinates = CLLocationCoordinate2D(latitude: listing.latitude, longitude: listing.longitude)
    listingId = listing.item.id
  }

  var name: String!
  var category: Int!
  var location: String!
  var coordinates: CLLocationCoordinate2D!
  var listingId: String!
}