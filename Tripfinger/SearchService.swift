import SKMaps

class SearchService: NSObject, SKSearchServiceDelegate {
    var handler: ([SKSearchResult] -> ())!
    let packageCode = "BE"
    
    override init() {
        super.init()
        SKSearchService.sharedInstance().searchServiceDelegate = self
        SKSearchService.sharedInstance().searchResultsNumber = 10000
    }

    func getCities(handler: [SKSearchResult] -> ()) {
        self.handler = handler
        self.searchMapData(SKListLevel.CityList, searchString: "", parent: 0)
    }
    
    func getStreetsForCity(identifier: UInt64, searchString: String, handler: [SKSearchResult] -> ()) {
        self.handler = handler
        self.searchMapData(SKListLevel.StreetList, searchString: searchString, parent: identifier)
    }
    
    func search(searchString: String, handler: [SKSearchResult] -> ()) {
        
        self.handler = handler
        getCities() {
            cities in
            
            var counter = 0
            var searchList = [SKSearchResult]()

            self.handler = {
                searchResults in
                
                searchList.appendContentsOf(searchResults)
                counter += 1
                if counter < cities.count {
                    let city = cities[counter]
                    self.searchMapData(SKListLevel.StreetList, searchString: searchString, parent: city.identifier)
                }
                else {
                    handler(searchList)
                }
            }

            let city = cities[counter]
            self.searchMapData(SKListLevel.StreetList, searchString: searchString, parent: city.identifier)
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
    
    func searchService(searchService: SKSearchService!, didRetrieveMultiStepSearchResults searchResults: [AnyObject]!) {
        
        handler(searchResults as! [SKSearchResult])
    }
    func searchServiceDidFailToRetrieveMultiStepSearchResults(searchService: SKSearchService!) {
        print("FAAAAIL")
    }
}