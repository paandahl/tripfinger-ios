import SKMaps
import RealmSwift

class SearchService: NSObject {
  
  let offlineSearch = OfflineSearch()
  var offlineResults = [SimplePOI]()
  var onlineResults = List<SimplePOI>()
  
  var citiesForStreetNames: [SKSearchResult]?
  var location: CLLocation?
  var proximityInKm: Double!
  
  /*
   * Location and proximity is used in offline street search, to limit workload
   */
  func setLocation(location: CLLocation, proximityInKm: Double) {
    citiesForStreetNames = nil // reset to make sure it's loaded again
    self.location = location
    self.proximityInKm = proximityInKm
  }

  func search(query: String, handler: [SimplePOI] -> ()) {

    offlineResults = [SimplePOI]()
    
    if NetworkUtil.connectedToNetwork() {
      OnlineSearch.search(query, gradual: true) {
        searchResults in
        
        self.onlineResults = searchResults
        var searchResults = [SimplePOI]()
        searchResults.appendContentsOf(self.onlineResults)
        searchResults.appendContentsOf(self.offlineResults)
      }
    }
    
    let handleStreetResults = { (results: [SimplePOI]) -> () in
      self.offlineResults.appendContentsOf(results)
      var searchResults = [SimplePOI]()
      searchResults.appendContentsOf(self.onlineResults)
      searchResults.appendContentsOf(self.offlineResults)
      handler(searchResults)
    }
    
    if citiesForStreetNames == nil {
      if let location = location {
        offlineSearch.getCitiesInProximityOf(location, proximityInKm: proximityInKm) { cities in
          self.offlineSearch.getStreetsForCities(query, cities: cities) { streets, finished in
            handleStreetResults(streets)
          }
         }
      }
    } else {
      offlineSearch.getStreets(query) { streets, finished in
        handleStreetResults(streets)
      }
    }
  }
}

