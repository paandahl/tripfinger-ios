import SKMaps

class SearchServiceDelegate: NSObject, SKSearchServiceDelegate {
  
  var handler: ([SKSearchResult] -> ())!
  var packageCode: String
  
  required init(handler: [SKSearchResult] -> (), packageCode: String) {
    self.handler = handler
    self.packageCode = packageCode
  }
  
  func searchService(searchService: SKSearchService!, didRetrieveMultiStepSearchResults searchResults: [AnyObject]!) {
    
    print("search results received")
    
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
  let varLock = dispatch_queue_create("SearchService.VarLock", nil)
  var searchRunning = false
  var threadCount = 0
  
  
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
      setDelegate { results in
        
        if results.count == 0 { // error, repeat query
          print("Got no cities fir country \(countryId). Retrying query.")
          self.getCities(forCountry: countryId, handler: handler)
        }
        else {
          handler(countryId, results, nil)
        }
      }
      self.searchMapData(SKListLevel.CityList, searchString: "", parent: 0)
    }
    else {
      let mapPackages = SKMapsService.sharedInstance().packagesManager.installedOfflineMapPackages as! [SKMapPackage]
      iterateThroughMapPackages(mapPackages, index: 0, handler: handler)
    }
  }
  
  func iterateThroughMapPackages(packages: [SKMapPackage], index: Int, handler: (String, [SKSearchResult], (() -> ())?) -> ())  {
    let mapPackage = packages[index]
    packageCode = mapPackage.name
    setDelegate() { results in
      
      if results.count == 0 { // error, repeat query
        print("Got no cities for country \(self.packageCode). Retrying query.")
        self.iterateThroughMapPackages(packages, index: index, handler: handler)
      }
      else {
        var callback: (() -> ())? = nil
        if index + 1 < packages.count {
          callback = {
            self.iterateThroughMapPackages(packages, index: index + 1, handler: handler)
          }
        }
        handler(mapPackage.name, results, callback)
      }
    }
    self.searchMapData(SKListLevel.CityList, searchString: "", parent: 0)
    
  }
  
  func getStreetsForCity(cityId: String, countryId: String, identifier: UInt64, searchString: String, handler: [SKSearchResult] -> ()) {
    setPackageCode(cityId, countryId: countryId)
    setDelegate(handler)
    self.searchMapData(SKListLevel.StreetList, searchString: searchString, parent: identifier)
  }
  
  func onlineSearch(fullSearchString: String, regionId: String? = nil, countryId: String? = nil, gradual: Bool = false, handler: [SearchResult] -> ()) {
    
    let escapedString = fullSearchString.stringByAddingPercentEncodingWithAllowedCharacters(.URLPathAllowedCharacterSet())!
    ContentService.getJsonFromUrl(ContentService.baseUrl + "/search/\(escapedString)", success: {
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
  
  func offlineSearch(fullSearchString: String, regionId: String? = nil, countryId: String? = nil, gradual: Bool = false, handler: [SearchResult] -> ()) {
    
    var threadId = 0
    SyncManager.synchronized(varLock) {
      self.threadCount += 1
      threadId = self.threadCount
    }
    let isCancelled: () -> Bool = {
      var isCancelled = false
      SyncManager.synchronized(self.varLock) {
        if threadId != self.threadCount {
          isCancelled = true
        }
      }
      if isCancelled {
        print("cancelling thread \(threadId), because there are \(self.threadCount)")
      }
      return isCancelled
    }
    
    SyncManager.run_async {
      
      print("Waiting for thread to unlock \(threadId)")
      SyncManager.block_until_condition(self, condition: {
        return self.searchRunning == false
        },
        after: {
          self.searchRunning = true
      })
      print("Got lock for thread \(threadId)")
      
      if isCancelled() {
        self.searchRunning = false
        return
      }
      
      var searchStrings = fullSearchString.characters.split{ $0 == " " }.map(String.init)
      searchStrings = searchStrings.sort { $0.characters.count > $1.characters.count }
      searchStrings = searchStrings.map {return $0.lowercaseString }
      let primarySearchString = searchStrings[0]
      let secondarySearchStrings = Array(searchStrings[1..<searchStrings.count])
      
      let countryId = countryId == nil ? regionId : countryId!
      print("offline searching for country: \(countryId)")
      
      self.getCities(forCountry: countryId) {
        packageId, cities, nextCountryHandler in
        
        print("Citiy packageId \(packageId)")
        print("Cities count \(cities.count)")
        var counter = 0
        var searchList = [SearchResult]()
        
        self.packageCode = packageId
        self.setDelegate() {
          searchResults in
          
          print("Entering delegate")
          
          counter += 1
          
          if isCancelled() {
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
            print("iterating to next city: \(city.name)")
            self.searchMapData(SKListLevel.StreetList, searchString: primarySearchString, parent: city.identifier)
          }
          else {
            handler(searchList)
            if let nextCountryHandler = nextCountryHandler {
              nextCountryHandler()
            }
            else {
              print("Finished thread: \(threadId)")
              self.searchRunning = false
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