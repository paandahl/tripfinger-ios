import RealmSwift
import Alamofire
import CoreLocation

class SearchService: NSObject {
  
  var onlineSearchRequest: Request?
  
  var skobblerResults = [SimplePOI]()
  var databaseResults = List<SimplePOI>()
  var onlineResults = List<SimplePOI>()
  
  func cancelSearch(callback: (() -> ())? = nil) {
    if let onlineSearchRequest = onlineSearchRequest {
      onlineSearchRequest.cancel()
    }
    if let callback = callback {
      callback()
    }
  }
  
  //TODO: Need to handle duplicates from online search and database
  func search(query: String, handler: [SimplePOI] -> ()) {

    onlineResults = List<SimplePOI>()
    databaseResults = List<SimplePOI>()
    
    let handleSearchResults = { (results: List<SimplePOI>) in
      dispatch_async(dispatch_get_main_queue()) {
        var searchResults = [SimplePOI]()
        searchResults.appendContentsOf(results)
        handler(searchResults)
      }
    }

    // Online search (regions and attractions)
    if NetworkUtil.connectedToNetwork() {
      onlineSearchRequest = OnlineSearch.search(query) { searchResults in
        handleSearchResults(searchResults)
      }
    } else {
      // Database search (regions, attractions)
      DatabaseService.search(query) { results in
        handleSearchResults(results)
      }
    }
  }
}

