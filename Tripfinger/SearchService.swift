import SKMaps

class SearchService: NSObject, SKSearchServiceDelegate {
    var handler: ([SKSearchResult] -> ())!

    func getCities(handler: [SKSearchResult] -> ()) {
        self.handler = handler
        SKSearchService.sharedInstance().searchServiceDelegate = self
        SKSearchService.sharedInstance().searchResultsNumber = 10000
        
        let multiStepSearchObject = SKMultiStepSearchSettings()
        multiStepSearchObject.listLevel = SKListLevel.CityList
        multiStepSearchObject.offlinePackageCode = "BECITY01"
        multiStepSearchObject.searchTerm = "forest"
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
        multiStepSearchObject.offlinePackageCode = "BECITY01"
        multiStepSearchObject.searchTerm = "altitude"
        multiStepSearchObject.parentIndex = identifier
        
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