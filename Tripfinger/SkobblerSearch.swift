import Foundation

class SkobblerSearch: NSObject {
  
  static let searchQueue = dispatch_queue_create("searchQueue", DISPATCH_QUEUE_SERIAL)
  let maxResults = 20
  var searchHandler: ([SKSearchResult] -> ())!
  var packageCode: String!
  var mapsObject: SKTMapsObject
  
  init(mapsObject: SKTMapsObject) {
    self.mapsObject = mapsObject
    SKSearchService.sharedInstance().searchResultsNumber = 10000
  }
  
  func cancelSearch() {
    SearchTask.cancel()
  }
  
  func isRunning() -> Bool {
    return SearchTask.runningTask != nil
  }
  
  func getCitiesInProximityOf(location: CLLocation, proximityInKm: Double, task: SearchTask! = nil, handler: [SimplePOI] -> ()) {
    runSearchTask(task) { task in

      var results = [SimplePOI]()
      self.getCities(task: task) { cities in
        
        for city in cities {
          let cityLocation = CLLocation(latitude: city.latitude, longitude: city.longitude)
          let distanceinKm = location.distanceFromLocation(cityLocation) / 1000
          if distanceinKm <= proximityInKm {
            results.append(city)
          }
        }
        task.decrementNestedCounter()
        handler(results)
      }
    }
  }
  
  func getCities(query: String = "", packageCode: String? = nil, task: SearchTask! = nil, handler: ([SimplePOI]) -> ()) {
    
    runSearchTask(task) { task in
      if let packageCode = packageCode {
        self.searchHandler = { results in
          
          if query == "" && results.count == 0 { // error, repeat query
            print("Got no cities for package '\(packageCode)'. Retrying query.")
            self.getCities(packageCode: packageCode, task: task, handler: handler)
          }
          else {
            task.decrementNestedCounter()
            let location = self.mapsObject.packageForCode(packageCode).nameForLanguageCode("en")
            handler(self.parseSearchResults(results, location: location))
          }
        }
        self.searchMapData(packageCode, listLevel: SKListLevel.CityList, searchString: query, parent: 0)
      }
      else {
        let mapPackages = SKMapsService.sharedInstance().packagesManager.installedOfflineMapPackages as! [SKMapPackage]
        if mapPackages.count > 0 {
          var allCities = [SimplePOI]()
          self.iterateThroughMapPackages(query, packages: mapPackages, index: 0) { cities, countryName, finished in
            allCities.appendContentsOf(self.parseSearchResults(cities, location: countryName))
            if finished {
              task.decrementNestedCounter()
              handler(allCities)
            }
          }
        }
        else {
          task.decrementNestedCounter()
          handler([SimplePOI]())
        }
      }
    }
  }
  
  internal func iterateThroughMapPackages(query: String, packages: [SKMapPackage], index: Int, handler: ([SKSearchResult], String, Bool) -> ())  {
    let mapPackage = packages[index]
    searchHandler = { results in
      
      if query == "" && results.count == 0 { // error, repeat query
        print("Got no cities for package '\(mapPackage.name)'. Retrying query.")
        self.iterateThroughMapPackages(query, packages: packages, index: index, handler: handler)
      }
      else {
        print("mapsObject: \(self.mapsObject)")
        print("mapPackage: \(mapPackage)")
        print("name: \(mapPackage.name)")
        let location = self.mapsObject.packageForCode(mapPackage.name).nameForLanguageCode("en")
        if index + 1 < packages.count {
          handler(results, location, false)
          self.iterateThroughMapPackages(query, packages: packages, index: index + 1, handler: handler)
        }
        else {
          handler(results, location, true)
        }
      }
    }
    self.searchMapData(mapPackage.name, listLevel: SKListLevel.CityList, searchString: query, parent: 0)
    
  }
  
  
  func getStreetsBulk(fullSearchString: String, handler: [SimplePOI] -> ()) {
    runSearchTask { task in
      var allSearchResults = [SimplePOI]()
      self.getStreets(fullSearchString, task: task) { streets, finished in
        
        allSearchResults.appendContentsOf(streets)
        
        if finished {
          task.decrementNestedCounter()
          handler(allSearchResults)
        }
      }
    }
  }
  
  func getStreets(fullSearchString: String, task: SearchTask! = nil, handler: ([SimplePOI], Bool) -> ()) {
    runSearchTask(task) { task in
      self.getCities(task: task) { cities in
        self.getStreetsForCities(fullSearchString, cities: cities, task: task, maxResultsTotal: self.maxResults) { streets, finished in
          if finished {
            task.decrementNestedCounter()
          }
          handler(streets, finished)
        }
      }
    }
  }
  
  func getStreetsForCities(query: String, cities: [SimplePOI], task: SearchTask! = nil, maxResultsTotal: Int = Int.max, handler: ([SimplePOI], Bool) -> ()) {

    runSearchTask(task) { task in
      print("Cities count \(cities.count)")
      var index = 0
      var numberOfResults = 0
      
      if cities.count == 0 {
        print("No cities offline")
        let thrower = {throw Error.RuntimeError("Hoi")}
        try! thrower()
        task.decrementNestedCounter()
        return
      }
      
      var inner_loop: (() -> ())!
      inner_loop = {
        
        let city = cities[index]
        self.getStreetsForCity(query, city: city, task: task, maxResults: maxResultsTotal) { streets in
          numberOfResults += streets.count
          
          index += 1
          if index < cities.count && numberOfResults < maxResultsTotal {
            if streets.count > 0 {
              handler(streets, false)              
            }
            
            inner_loop()
            
            print("iterating to next city: \(cities[index].name)")
          }
          else {
            task.decrementNestedCounter()
            handler(streets, true)
          }
          
        }
      }
      inner_loop()
    }
  }
  
  func getStreetsForCity(query: String, city: SimplePOI, task: SearchTask! = nil, maxResults: Int = Int.max, handler: [SimplePOI] -> ()) {
    
    runSearchTask(task) { task in
      var searchStrings = query.characters.split{ $0 == " " }.map(String.init)
      searchStrings = searchStrings.sort { $0.characters.count > $1.characters.count }
      searchStrings = searchStrings.map {return $0.lowercaseString }
      let primaryQuery = searchStrings[0]
      let secondarySearchStrings = Array(searchStrings[1..<searchStrings.count])
      
      self.searchHandler = {
        streets in
        
        var streetsToParse = self.filterSearchResults(streets, secondarySearchStrings: secondarySearchStrings)
        if streetsToParse.count > maxResults {
          streetsToParse = Array(streetsToParse[0..<maxResults])
        }
        let parsedStreets = self.parseSearchResults(streetsToParse, location: city.name)
        task.decrementNestedCounter()
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
  
  func parseSearchResults(skobblerResults: [SKSearchResult], location: String) -> [SimplePOI] {
    
    var searchResults = [SimplePOI]()
    for skobblerResult in skobblerResults {
      searchResults.append(parseSearchResult(skobblerResult, location: location))
    }
    return searchResults
  }
  
  private func parseSearchResult(skobblerResult: SKSearchResult, location: String) -> SimplePOI {
    
    let searchResult = SimplePOI()
    searchResult.name = skobblerResult.name
    
    searchResult.latitude = skobblerResult.coordinate.latitude
    searchResult.longitude = skobblerResult.coordinate.longitude
    searchResult.location = location
    searchResult.category = 180
    searchResult.identifier = skobblerResult.identifier
    searchResult.offlinePackageCode = skobblerResult.offlinePackageCode
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
    var nestedCounter = 0
    
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
    
    func incrementNestedCounter() {
      nestedCounter = nestedCounter + 1
    }
    
    func decrementNestedCounter() {
      nestedCounter = nestedCounter - 1
      if nestedCounter == 0 {
        SearchTask.setRunningTask(nil)
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
      task.incrementNestedCounter()
      SKSearchService.sharedInstance().searchServiceDelegate = self
      closure(task)
    }
    
    if task == nil {
      task = SearchTask()
      dispatch_async(SkobblerSearch.searchQueue) {
        runTask()
        self.waitUntilSearchFinished()
        print("Finished task: \(task.taskId)")
      }
    }
    else {
      runTask()
    }
  }
  
  internal func waitUntilSearchFinished() {
    SyncManager.block_until_condition(SKSearchService.sharedInstance(), condition: {
      return SearchTask.runningTask == nil
      })
  }
  
}

extension SkobblerSearch: SKSearchServiceDelegate {
  
  func searchService(searchService: SKSearchService!, didRetrieveMultiStepSearchResults searchResults: [AnyObject]!) {
    
    print("search results received: \(searchResults.count)")
    searchHandler(searchResults as! [SKSearchResult])
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