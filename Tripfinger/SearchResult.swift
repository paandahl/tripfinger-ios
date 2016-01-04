import Foundation
import RealmSwift

class SearchResult: Object {
  
  var name: String!
  var category: Int!
  var location: String!
  var latitude: Double!
  var longitude: Double!
  var listingId: String?
}