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
    
    func search(fullSearchString: String, handler: [SearchResult] -> ()) {
        SyncManager.run_async() {
            
            var searchStrings = fullSearchString.characters.split{ $0 == " " }.map(String.init)
            searchStrings = searchStrings.sort { $0.characters.count > $1.characters.count }
            searchStrings = searchStrings.map {return $0.lowercaseString }
            let primarySearchString = searchStrings[0]
            let secondarySearchStrings = Array(searchStrings[1..<searchStrings.count])

            if self.searchRunning {
                SKSearchService.sharedInstance().cancelSearch()
                self.searchCancelled = true
                usleep(100 * 1000)
            }

            self.searchCancelled = false
            self.searchRunning = true
            self.getCities() {
                cities in
                
                var counter = 0
                var searchList = [SearchResult]()
                
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
                    let city = cities[counter - 1]
                    let parsedResults = self.parseSearchResults(resultsToParse, city: city.name)
                    searchList.appendContentsOf(parsedResults)
                
                    if counter < cities.count && !listIsFull {
                        let city = cities[counter]
                        self.searchMapData(SKListLevel.StreetList, searchString: primarySearchString, parent: city.identifier)
                    }
                    else {
                        self.searchRunning = false
                        handler(searchList)
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
        searchResult.city = city
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