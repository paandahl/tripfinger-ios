import SKMaps

class SearchServiceDelegate: NSObject, SKSearchServiceDelegate {
    
    var handler: ([SKSearchResult] -> ())!
    
    required init(handler: [SKSearchResult] -> ()) {
        self.handler = handler
    }

    func searchService(searchService: SKSearchService!, didRetrieveMultiStepSearchResults searchResults: [AnyObject]!) {

        self.handler(searchResults as! [SKSearchResult])
    }
    
    func searchServiceDidFailToRetrieveMultiStepSearchResults(searchService: SKSearchService!) {
        print("FAAAAIL")
    }
}

class SearchService {
    let packageCode = "BE"
    let maxResults = 20
    var delegate: SearchServiceDelegate?
    var searchRunning = false
    var searchCancelled = false
    
    init() {
        SKSearchService.sharedInstance().searchResultsNumber = 10000
    }
    
    func setDelegate(handler: [SKSearchResult] -> ()) {
        delegate = SearchServiceDelegate(handler: handler)
        SKSearchService.sharedInstance().searchServiceDelegate = delegate
    }

    func getCities(handler: [SKSearchResult] -> ()) {
        setDelegate(handler)
        self.searchMapData(SKListLevel.CityList, searchString: "", parent: 0)
    }
    
    func getStreetsForCity(identifier: UInt64, searchString: String, handler: [SKSearchResult] -> ()) {
        setDelegate(handler)
        self.searchMapData(SKListLevel.StreetList, searchString: searchString, parent: identifier)
    }
    
    func cancelSearch() {
    }
    
    func search(searchString: String, handler: [SKSearchResult] -> ()) {
        SyncManager.run_async() {
            if self.searchRunning {
                print("Cancelling search")
                SKSearchService.sharedInstance().cancelSearch()
                self.searchCancelled = true
                
                usleep(100 * 1000)
//                while (self.searchRunning) {
//                }
                print("Cancelled search")
            }
            print("Running search")
            
            self.searchCancelled = false
            self.searchRunning = true
            self.getCities() {
                cities in
                
                print("got cities")
                var counter = 0
                let city = cities[counter]
                var searchList = [SKSearchResult]()
                
                self.setDelegate() {
                    searchResults in
                    
                    if self.searchCancelled {
                        self.searchRunning = false
                        return
                    }
                    searchList.appendContentsOf(searchResults)
                    counter += 1
                    if searchList.count >= self.maxResults {
                        searchList = Array(searchList[0..<self.maxResults])
                        self.searchRunning = false
                        handler(searchList)
                    }
                    else if counter < cities.count {
                        let city = cities[counter]
                        self.searchMapData(SKListLevel.StreetList, searchString: searchString, parent: city.identifier)
                    }
                    else {
                        self.searchRunning = false
                        handler(searchList)
                    }
                }
                
                self.searchMapData(SKListLevel.StreetList, searchString: searchString, parent: city.identifier)
            }
        }
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