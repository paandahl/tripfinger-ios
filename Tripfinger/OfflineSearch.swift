import Foundation

class OfflineSearch: NSObject {
  
  static let searchQueue = dispatch_queue_create("searchQueue", DISPATCH_QUEUE_SERIAL)
  let maxResults = 20
  var searchHandler: ([SKSearchResult] -> ())!
  var packageCode: String!
  
  override init() {
    super.init()
    SKSearchService.sharedInstance().searchResultsNumber = 10000
  }
  
  func cancelSearch() {
    SearchTask.cancel()
  }
  
  func getCitiesInProximityOf(location: CLLocation, proximityInKm: Double, task: SearchTask! = nil, handler: [SKSearchResult] -> ()) {
    runSearchTask(task) { task in

      var results = [SKSearchResult]()
      self.getCities(task: task) { cities in
        
        for city in cities {
          let cityLocation = CLLocation(latitude: city.coordinate.latitude, longitude: city.coordinate.longitude)
          let distanceinKm = location.distanceFromLocation(cityLocation) / 1000
          if distanceinKm <= proximityInKm {
            results.append(city)
          }
        }
        handler(results)
      }
    }
  }
  
  func getCities(packageCode: String? = nil, task: SearchTask! = nil, handler: ([SKSearchResult]) -> ()) {
    
    runSearchTask(task) { task in
      if let packageCode = packageCode {
        self.searchHandler = { results in
          
          if results.count == 0 { // error, repeat query
            print("Got no cities for package \(packageCode). Retrying query.")
            self.getCities(packageCode, handler: handler)
          }
          else {
            handler(results)
          }
        }
        self.searchMapData(packageCode, listLevel: SKListLevel.CityList, searchString: "", parent: 0)
      }
      else {
        let mapPackages = SKMapsService.sharedInstance().packagesManager.installedOfflineMapPackages as! [SKMapPackage]
        if mapPackages.count > 0 {
          var allCities = [SKSearchResult]()
          self.iterateThroughMapPackages(mapPackages, index: 0) { cities, finished in
            allCities.appendContentsOf(cities)
            if finished {
              handler(allCities)
            }
          }
        }
        else {
          handler([SKSearchResult]())
        }
      }
    }
  }
  
  func iterateThroughMapPackages(packages: [SKMapPackage], index: Int, handler: ([SKSearchResult], Bool) -> ())  {
    let mapPackage = packages[index]
    searchHandler = { results in
      
      if results.count == 0 { // error, repeat query
        print("Got no cities for country \(packages[index].name). Retrying query.")
        self.iterateThroughMapPackages(packages, index: index, handler: handler)
      }
      else {
        if index + 1 < packages.count {
          handler(results, false)
          self.iterateThroughMapPackages(packages, index: index + 1, handler: handler)
        }
        else {
          handler(results, true)
        }
      }
    }
    self.searchMapData(mapPackage.name, listLevel: SKListLevel.CityList, searchString: "", parent: 0)
    
  }
  
  
  func getStreetsBulk(fullSearchString: String, handler: [SimplePOI] -> ()) {
    runSearchTask { task in
      var allSearchResults = [SimplePOI]()
      self.getStreets(fullSearchString, task: task) { streets, finished in
        
        allSearchResults.appendContentsOf(streets)
        
        if finished {
          handler(allSearchResults)
        }
      }
    }
  }
  
  func getStreets(fullSearchString: String, task: SearchTask! = nil, handler: ([SimplePOI], Bool) -> ()) {
    runSearchTask(task) { task in
      self.getCities(task: task) { cities in
        self.getStreetsForCities(fullSearchString, cities: cities, task: task, handler: handler)
      }
    }
  }
  
  func getStreetsForCities(query: String, cities: [SKSearchResult], task: SearchTask! = nil, maxResultsTotal: Int? = Int.max, handler: ([SimplePOI], Bool) -> ()) {

    runSearchTask(task) { task in
      print("Cities count \(cities.count)")
      var index = 0
      var numberOfResults = 0
      
      if cities.count == 0 {
        print("No cities offline")
        SearchTask.setRunningTask(nil)
        return
      }
      
      var inner_loop: (() -> ())!
      inner_loop = {
        
        let city = cities[index]
        self.getStreetsForCity(query, city: city, task: task, maxResults: maxResultsTotal) { streets in
          
          numberOfResults += streets.count
          
          index += 1
          if index < cities.count && numberOfResults < maxResultsTotal {
            handler(streets, false)
            
            inner_loop()
            
            print("iterating to next city: \(cities[index].name)")
          }
          else {
            SearchTask.setRunningTask(nil)
            SearchTask.setRunningTask(nil)
            handler(streets, true)
          }
          
        }
      }
      inner_loop()
    }
  }
  
  //  func getStreetsForCity(cityId: String, countryId: String, identifier: UInt64, searchString: String, handler: [SKSearchResult] -> ()) {
  //    setPackageCode(cityId, countryId: countryId)
  //    searchHandler = handler
  //    self.searchMapData(SKListLevel.StreetList, searchString: searchString, parent: identifier)
  //  }
  
  func getStreetsForCity(query: String, city: SKSearchResult, task: SearchTask! = nil, maxResults: Int? = Int.max, handler: [SimplePOI] -> ()) {
    
    runSearchTask(task) { task in
      var searchStrings = query.characters.split{ $0 == " " }.map(String.init)
      searchStrings = searchStrings.sort { $0.characters.count > $1.characters.count }
      searchStrings = searchStrings.map {return $0.lowercaseString }
      let primaryQuery = searchStrings[0]
      let secondarySearchStrings = Array(searchStrings[1..<searchStrings.count])
      
      self.searchHandler = {
        streets in
        
        var streetsToParse = self.filterSearchResults(streets, secondarySearchStrings: secondarySearchStrings)
        if let maxResults = maxResults where streets.count > maxResults {
          streetsToParse = Array(streetsToParse[0..<maxResults])
        }
        let parsedStreets = self.parseSearchResults(streetsToParse, city: city.name)
        handler(parsedStreets)
      }
      
      self.searchMapData(city.offlinePackageCode, listLevel: SKListLevel.StreetList, searchString: primaryQuery, parent: city.identifier)
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
  
  private func parseSearchResults(skobblerResults: [SKSearchResult], city: String) -> [SimplePOI] {
    
    var searchResults = [SimplePOI]()
    for skobblerResult in skobblerResults {
      searchResults.append(parseSearchResult(skobblerResult, city: city))
    }
    return searchResults
  }
  
  private func parseSearchResult(skobblerResult: SKSearchResult, city: String) -> SimplePOI {
    
    let searchResult = SimplePOI()
    searchResult.name = skobblerResult.name
    
    searchResult.latitude = skobblerResult.coordinate.latitude
    searchResult.longitude = skobblerResult.coordinate.longitude
    searchResult.location = city
    searchResult.category = 180
    return searchResult
  }
  
  private func searchMapData(packageCode: String, listLevel: SKListLevel, searchString: String, parent: UInt64) {
    self.packageCode = packageCode
    let multiStepSearchObject = SKMultiStepSearchSettings()
    multiStepSearchObject.listLevel = listLevel
    multiStepSearchObject.offlinePackageCode = packageCode
    multiStepSearchObject.searchTerm = searchString
    multiStepSearchObject.parentIndex = parent
    
    let searcher = MultiStepSearchViewController()
    searcher.multiStepObject = multiStepSearchObject
    searcher.fireSearch()
  }
  
  internal class SearchTask {
    
    static var runningTask: SearchTask?
    static let varLock = dispatch_queue_create("SearchService.VarLock", nil)
    static var taskCounter = 0
    var taskId = 0
    
    required init() {
      SyncManager.synchronized(SearchTask.varLock) {
        SearchTask.taskCounter += 1
        self.taskId = SearchTask.taskCounter
      }
    }
    
    class func cancel() {
      SyncManager.synchronized(SearchTask.varLock) {
        SearchTask.taskCounter += 1
      }
    }
    
    class func setRunningTask(task: SearchTask?) {
      SyncManager.synchronized(SearchTask.varLock) {
        SearchTask.runningTask = task
      }
    }
    
    func isCancelled() -> Bool {
      var isCancelled = false
      SyncManager.synchronized(SearchTask.varLock) {
        if self.taskId != SearchTask.taskCounter {
          isCancelled = true
        }
      }
      if isCancelled {
        print("cancelling thread \(self.taskId), because there are \(SearchTask.taskCounter)")
      }
      return isCancelled
    }
    
    func run(isRunning: () -> Bool, setRunning: Bool -> ()) {
      
    }
  }
  
  internal func runSearchTask(var task: SearchTask! = nil, closure: SearchTask -> ()) {

    let runTask = {
      if task.isCancelled() {
        SearchTask.setRunningTask(nil)
        return
      }
      SKSearchService.sharedInstance().searchServiceDelegate = self
      closure(task)
    }
    
    if task == nil {
      task = SearchTask()
      dispatch_async(OfflineSearch.searchQueue) {
        runTask()
        self.waitUntilSearchFinished(task)
        SearchTask.setRunningTask(nil)
        print("Finished task: \(task.taskId)")
      }
    }
    else {
      runTask()
    }
  }
  
  internal func waitUntilSearchFinished(task: SearchTask) {
    SyncManager.block_until_condition(SKSearchService.sharedInstance(), condition: {
      return SearchTask.runningTask == nil
      },
      after: {
        SearchTask.setRunningTask(task)
    })
  }
  
}

extension OfflineSearch: SKSearchServiceDelegate {
  
  func searchService(searchService: SKSearchService!, didRetrieveMultiStepSearchResults searchResults: [AnyObject]!) {
    
    print("search results received")
    self.searchHandler(searchResults as! [SKSearchResult])
  }
  
  func searchServiceDidFailToRetrieveMultiStepSearchResults(searchService: SKSearchService!) {
    
    if !DownloadService.hasMapPackage(self.packageCode) {
      print("Tried to search in package not installed: " + self.packageCode)
    }
    else {
      print("Unknown failure with search")
    }
    
    SearchTask.setRunningTask(nil)
  }
}