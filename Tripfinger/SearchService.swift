import SKMaps
import RealmSwift
import Alamofire

class SearchService: NSObject {
  
  let skobblerSearch: SkobblerSearch
  var onlineSearchRequest: Request?
  
  var skobblerResults = [SimplePOI]()
  var databaseResults = List<SimplePOI>()
  var onlineResults = List<SimplePOI>()
  
  required override init() {
    print("initz")
    self.skobblerSearch = SkobblerSearch()
  }
  
  /*
  * Location and proximity is used in offline street search, to limit workload
  */
  func setLocation(location: CLLocation, proximityInKm: Double) {
    skobblerSearch.setLocation(location, proximityInKm: proximityInKm)
  }
  
  func cancelSearch(callback: (() -> ())? = nil) {
    skobblerSearch.cancelSearch(callback)
    if let onlineSearchRequest = onlineSearchRequest {
      onlineSearchRequest.cancel()
    }
  }
  
  //TODO: Need to handle duplicates from online, database and skobbler search
  func search(query: String, handler: [SimplePOI] -> ()) {

    onlineResults = List<SimplePOI>()
    databaseResults = List<SimplePOI>()
    skobblerResults = [SimplePOI]()
    
    let handleSearchResults = {
      dispatch_async(dispatch_get_main_queue()) {
        var searchResults = [SimplePOI]()
        searchResults.appendContentsOf(self.onlineResults)
        searchResults.appendContentsOf(self.databaseResults)
        searchResults.appendContentsOf(self.skobblerResults)
        handler(searchResults)        
      }
    }

    // Online search (regions and attractions)
    if NetworkUtil.connectedToNetwork() {
      onlineSearchRequest = OnlineSearch.search(query) { searchResults in
        self.onlineResults = searchResults
        handleSearchResults()
      }
    }
    
    // Database search (regions, attractions and simplePois)
    DatabaseService.search(query) { results in
      self.databaseResults = results
      handleSearchResults()
    }
    
    // Skobbler search (cities and street names)
    skobblerSearch.search(query) { results in
      self.skobblerResults.appendContentsOf(results)
      handleSearchResults()
      
    }
  }
}

