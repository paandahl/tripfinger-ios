import SKMaps

class SearchServiceDelegate: NSObject, SKSearchServiceDelegate {
  
  var handler: ([SKSearchResult] -> ())!
  var packageCode: String
  
  required init(handler: [SKSearchResult] -> (), packageCode: String) {
    self.handler = handler
    self.packageCode = packageCode
  }
  
  func searchService(searchService: SKSearchService!, didRetrieveMultiStepSearchResults searchResults: [AnyObject]!) {
    
    self.handler(searchResults as! [SKSearchResult])
  }
  
  func searchServiceDidFailToRetrieveMultiStepSearchResults(searchService: SKSearchService!) {
    if !DownloadService.hasMapPackage(packageCode) {
      print("Tried to search in package not installed: " + packageCode)
    }
    else {
      print("Unknown failure with search")
    }
  }
}

class SearchService {
  let maxResults = 20
  var packageCode: String!
  var delegate: SearchServiceDelegate?
  var searchRunning = false
  var searchCancelled = false
  
  init() {
    SKSearchService.sharedInstance().searchResultsNumber = 10000
  }
  
  func setDelegate(handler: [SKSearchResult] -> ()) {
    delegate = SearchServiceDelegate(handler: handler, packageCode: packageCode)
    SKSearchService.sharedInstance().searchServiceDelegate = delegate
  }
  
  private func setPackageCode(regionId: String, countryId: String) {
    if regionId != countryId && DownloadService.hasMapPackage(regionId) {
      packageCode = regionId
    }
    else {
      packageCode = countryId
    }
  }

  func getCities(forCountry countryId: String? = nil, handler: (String, [SKSearchResult], (() -> ())?) -> ()) {
    if let countryId = countryId {
      setPackageCode(countryId, countryId: countryId)
      setDelegate() { results in handler(countryId, results, nil) }
      self.searchMapData(SKListLevel.CityList, searchString: "", parent: 0)
    }
    else {
      let mapPackages = SKMapsService.sharedInstance().packagesManager.installedOfflineMapPackages as! [SKMapPackage]
      iterateThroughMapPackages(mapPackages, index: 0, handler: handler)
    }
  }
  
  func iterateThroughMapPackages(packages: [SKMapPackage], index: Int, handler: (String, [SKSearchResult], (() -> ())?) -> ())  {
    if index < packages.count {
      let mapPackage = packages[index]
      packageCode = mapPackage.name
      setDelegate() { results in
        handler(mapPackage.name, results) {
          self.iterateThroughMapPackages(packages, index: index + 1, handler: handler)
        }
      }
    }
  }
  
  func getStreetsForCity(cityId: String, countryId: String, identifier: UInt64, searchString: String, handler: [SKSearchResult] -> ()) {
    setPackageCode(cityId, countryId: countryId)
    setDelegate(handler)
    self.searchMapData(SKListLevel.StreetList, searchString: searchString, parent: identifier)
  }
  
  func cancelSearch() {
  }

  func onlineSearch(fullSearchString: String, regionId: String? = nil, countryId: String? = nil, gradual: Bool = false, handler: [SearchResult] -> ()) {
    ContentService.getJsonFromUrl(ContentService.baseUrl + "/search/\(fullSearchString)", success: {
      json in
      
      let searchResults = self.parseSearchResults(json)
      
      dispatch_async(dispatch_get_main_queue()) {
        handler(searchResults)
      }
      }, failure: nil)
  }
  
  func parseSearchResults(json: JSON) -> [SearchResult] {
    var searchResults = [SearchResult]()
    for resultJson in json.array! {
      let searchResult = SearchResult()
      searchResult.name = resultJson["name"].string!
      searchResult.longitude = resultJson["longitude"].double!
      searchResult.latitude = resultJson["latitude"].double!
      searchResults.append(searchResult)
    }
    return searchResults
  }

  func offlineSearch(fullSearchString: String, regionId: String?, countryId: String? = nil, gradual: Bool = false, handler: [SearchResult] -> ()) {
    SyncManager.run_async() {
      
      var searchStrings = fullSearchString.characters.split{ $0 == " " }.map(String.init)
      searchStrings = searchStrings.sort { $0.characters.count > $1.characters.count }
      searchStrings = searchStrings.map {return $0.lowercaseString }
      let primarySearchString = searchStrings[0]
      let secondarySearchStrings = Array(searchStrings[1..<searchStrings.count])
      
      if self.searchRunning {
        self.searchCancelled = true
        while (self.searchRunning) {
          usleep(10 * 1000)
        }
      }
      
      self.searchCancelled = false
      self.searchRunning = true
      let countryId = countryId == nil ? regionId : countryId!
      self.getCities(forCountry: countryId) {
        packageId, cities, nextCountryHandler in
        
        var counter = 0
        var searchList = [SearchResult]()
        
        self.packageCode = packageId
        self.setDelegate() {
          searchResults in
          
          counter += 1
          
          if self.searchCancelled {
            self.searchRunning = false
            return
          }
          
          var resultsToParse = self.filterSearchResults(searchResults, secondarySearchStrings: secondarySearchStrings)
          var listIsFull = false
          if (searchList.count + resultsToParse.count) >= self.maxResults {
            let willTake = self.maxResults - searchList.count
            resultsToParse = Array(resultsToParse[0..<willTake])
            listIsFull = true
          }
          print("cites: \(cities.count)")
          let city = cities[counter - 1]
          let parsedResults = self.parseSearchResults(resultsToParse, city: city.name)
          searchList.appendContentsOf(parsedResults)
          
          if counter < cities.count && !listIsFull {
            
            if gradual && parsedResults.count > 0 {
              handler(searchList)
            }
            let city = cities[counter]
            self.searchMapData(SKListLevel.StreetList, searchString: primarySearchString, parent: city.identifier)
          }
          else {
            self.searchRunning = false
            handler(searchList)
            if let nextCountryHandler = nextCountryHandler {
              nextCountryHandler()
            }
          }
        }
        
        let city = cities[counter]
        self.searchMapData(SKListLevel.StreetList, searchString: primarySearchString, parent: city.identifier)
      }
    }
  }
  
  private func filterSearchResults(results: [SKSearchResult], secondarySearchStrings: [String]) -> [SKSearchResult] {
    if (secondarySearchStrings.count == 0 || results.count == 0) {
      return results
    }
    var filteredResults = [SKSearchResult]()
    for result in results {
      let nameParts = result.name.lowercaseString.characters.split{ $0 == " " }.map(String.init)
      
      if (secondarySearchStrings.reduce(true) {
        (acc, value) in
        
        return acc && nameParts.reduce(false) { $0 || $1.hasPrefix(value) }
        })
      {
        filteredResults.append(result)
      }
    }
    return filteredResults
  }
  
  private func parseSearchResults(skobblerResults: [SKSearchResult], city: String) -> [SearchResult] {
    
    var searchResults = [SearchResult]()
    for skobblerResult in skobblerResults {
      searchResults.append(parseSearchResult(skobblerResult, city: city))
    }
    return searchResults
  }
  
  private func parseSearchResult(skobblerResult: SKSearchResult, city: String) -> SearchResult {
    
    let searchResult = SearchResult()
    searchResult.name = skobblerResult.name
    searchResult.latitude = skobblerResult.coordinate.latitude
    searchResult.longitude = skobblerResult.coordinate.longitude
    searchResult.location = city
    searchResult.resultType = .Street
    return searchResult
  }
  
  private func searchMapData(listLevel: SKListLevel, searchString: String, parent: UInt64) {
    let multiStepSearchObject = SKMultiStepSearchSettings()
    multiStepSearchObject.listLevel = listLevel
    multiStepSearchObject.offlinePackageCode = self.packageCode
    multiStepSearchObject.searchTerm = searchString
    multiStepSearchObject.parentIndex = parent
    
    let searcher = MultiStepSearchViewController()
    searcher.multiStepObject = multiStepSearchObject
    searcher.fireSearch()
  }
  
}