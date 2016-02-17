import SKMaps
import RealmSwift

class SearchService: NSObject {
  
  let skobblerSearch: SkobblerSearch
  var skobblerResults = [SimplePOI]()
  var databaseResults = List<SimplePOI>()
  var onlineResults = List<SimplePOI>()
  
  var citiesForStreetNames: [SimplePOI]?
  var location: CLLocation?
  var proximityInKm: Double!
  
  required init(mapsObject: SKTMapsObject) {
    print("initz")
    self.skobblerSearch = SkobblerSearch(mapsObject: mapsObject)
  }
  
  /*
  * Location and proximity is used in offline street search, to limit workload
  */
  func setLocation(location: CLLocation, proximityInKm: Double) {
    citiesForStreetNames = nil // reset to make sure it's loaded again
    self.location = location
    self.proximityInKm = proximityInKm
  }
  
  func cancelSearch(callback: () -> ()) {
    skobblerSearch.cancelSearch(callback)
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
      OnlineSearch.search(query, gradual: true) { searchResults in
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
    skobblerSearch.getCities(query) { cities in
      self.skobblerResults = cities
      print("passing on \(cities.count) city results")
      handleSearchResults()
      
      if let location = self.location {
        if let citiesForStreetNames = self.citiesForStreetNames {
          self.skobblerSearch.getStreetsForCities(query, cities: citiesForStreetNames) { streets, finished in
            self.skobblerResults.appendContentsOf(streets)
            handleSearchResults()
          }
        }
        else {
          self.skobblerSearch.getCitiesInProximityOf(location, proximityInKm: self.proximityInKm) { cities in
            self.citiesForStreetNames = cities
            self.skobblerSearch.getStreetsForCities(query, cities: cities) { streets, finished in
              self.skobblerResults.appendContentsOf(streets)
              handleSearchResults()
            }
          }
        }
      } else {
        self.skobblerSearch.getStreets(query) { streets, finished in
          self.skobblerResults.appendContentsOf(streets)
          handleSearchResults()
        }
      }
    }
  }
}

