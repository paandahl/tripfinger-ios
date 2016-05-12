import RealmSwift
import Alamofire
import CoreLocation

class SearchService: NSObject {
  
  var onlineSearchRequest: Request?
  
  var skobblerResults = [SimplePOI]()
  var databaseResults = List<SimplePOI>()
  var onlineResults = List<SimplePOI>()
  
  required override init() {
    print("initz")
  }
  
  /*
  * Location and proximity is used in offline street search, to limit workload
  */
  func setLocation(location: CLLocation, proximityInKm: Double) {
//    skobblerSearch.setLocation(location, proximityInKm: proximityInKm)
  }
  
  func cancelSearch(callback: (() -> ())? = nil) {
//    skobblerSearch.cancelSearch(callback)
    if let onlineSearchRequest = onlineSearchRequest {
      onlineSearchRequest.cancel()
    }
    if let callback = callback {
      callback()
    }
  }
  
  //TODO: Need to handle duplicates from online, database and skobbler search
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
      // Database search (regions, attractions and simplePois)
      DatabaseService.search(query) { results in
        handleSearchResults(results)
      }
    }
  }
}

