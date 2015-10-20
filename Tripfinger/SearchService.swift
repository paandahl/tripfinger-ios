import SKMaps

class SearchService: NSObject, SKSearchServiceDelegate {
    var handler: ([SKSearchResult] -> ())!
    let packageCode = "BE"

    func getCities(handler: [SKSearchResult] -> ()) {
        self.handler = handler
        SKSearchService.sharedInstance().searchServiceDelegate = self
        SKSearchService.sharedInstance().searchResultsNumber = 10000
        
        let multiStepSearchObject = SKMultiStepSearchSettings()
        multiStepSearchObject.listLevel = SKListLevel.CityList
        multiStepSearchObject.offlinePackageCode = "BE"
        multiStepSearchObject.searchTerm = ""
        multiStepSearchObject.parentIndex = 0
        
        let searcher = MultiStepSearchViewController()
        searcher.multiStepObject = multiStepSearchObject
        searcher.fireSearch()
    }
    
    func getStreetsForCity(identifier: UInt64, handler: [SKSearchResult] -> ()) {
        self.handler = handler
        SKSearchService.sharedInstance().searchServiceDelegate = self
        SKSearchService.sharedInstance().searchResultsNumber = 10000
        
        let multiStepSearchObject = SKMultiStepSearchSettings()
        multiStepSearchObject.listLevel = SKListLevel.StreetList
        multiStepSearchObject.offlinePackageCode = packageCode
        multiStepSearchObject.searchTerm = "altitude"
        multiStepSearchObject.parentIndex = 0
        
        let searcher = MultiStepSearchViewController()
        searcher.multiStepObject = multiStepSearchObject
        searcher.fireSearch()
    }
    
    func search(searchString: String, handler: [SKSearchResult] -> ()) {
        
        self.handler = handler
        getCities() {
            cities in
            
            var counter = 0
            var searchList = [SKSearchResult]()

            self.handler = {
                searchResults in
                
                if searchResults.count > 0 {
                    print("Retrieved \(searchResults.count) results from \(searchResults[0].parentSearchResults)")
                }
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