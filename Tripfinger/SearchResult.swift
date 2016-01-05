import Foundation
import RealmSwift

class SearchResult: Object {
  
  var name: String!
  var category: Int!
  var location: String!
  var coordinates: CLLocationCoordinate2D!
  var listingId: String!
}