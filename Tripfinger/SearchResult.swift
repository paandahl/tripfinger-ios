import Foundation

class SearchResult {
  
  var name: String!
  var category: String!
  var location: String!
  var latitude: Double!
  var longitude: Double!
  var resultType: ResultType!
  
  enum ResultType: Int {
    case Street = 1
  }
  
}