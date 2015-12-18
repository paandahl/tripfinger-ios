import Foundation

protocol SearchViewControllerDelegate: class {
  func selectedSearchResult(searchResult: SearchResult)
}

class SearchController: UITableViewController {
  
  var regionId: String?
  var countryId: String?
  
  var delegate: SearchViewControllerDelegate?
  var searchService: SearchService!
  var searchController: UISearchController!
  var searchBarItem: UIBarButtonItem!
  
  var offlineResults = [SearchResult]()
  var onlineResults = [SearchResult]()
  var searchResults = [SearchResult]()
  var searchText = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    searchService = SearchService()
    
    searchController = UISearchController(searchResultsController: nil)
    searchController.searchResultsUpdater = self
    searchController.delegate = self
    searchController.dimsBackgroundDuringPresentation = false
    searchController.hidesNavigationBarDuringPresentation = false
    
    // Make sure the that the search bar is visible within the navigation bar.
    searchController.searchBar.delegate = self
    searchController.searchBar.sizeToFit()
    
    // Include the search controller's search bar within the table's header view.
    searchBarItem = UIBarButtonItem(customView: searchController.searchBar)
    self.navigationItem.titleView = searchController.searchBar
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    searchController.active = true
  }
}

// MARK: - Search controller functionality

extension SearchController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
  
  func updateSearchResultsForSearchController(searchController: UISearchController) {
    let newSearchText = searchController.searchBar.text!
    if (newSearchText.characters.count > 1 && newSearchText != searchText) {
      
      self.offlineResults = [SearchResult]()
      searchText = newSearchText
      
      if connectedToNetwork() {
        searchService.onlineSearch(searchText, regionId: regionId, countryId: countryId, gradual: true) {
          searchResults in
          
          self.onlineResults = searchResults
          self.searchResults = [SearchResult]()
          self.searchResults.appendContentsOf(self.onlineResults)
          self.searchResults.appendContentsOf(self.offlineResults)
          self.tableView.reloadData()
        }
      }
      searchService.offlineSearch(searchText, regionId: regionId, countryId: countryId) {
        city, searchResults, nextCityHandler in
        
        self.offlineResults.appendContentsOf(searchResults)
        self.searchResults = [SearchResult]()
        self.searchResults.appendContentsOf(self.onlineResults)
        self.searchResults.appendContentsOf(self.offlineResults)
        self.tableView.reloadData()
        if let nextCityHandler = nextCityHandler {
          nextCityHandler()
        }
      }
    }
  }
  
  func didPresentSearchController(searchController: UISearchController) {
    searchController.searchBar.becomeFirstResponder()
  }
  
  func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func searchBarTextDidEndEditing(searchBar: UISearchBar) {
    dismissViewControllerAnimated(true, completion: nil)
    
  }
}

// MARK: - Talbeview Data Source

extension SearchController {
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return searchResults.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("SearchResultCell")
    if cell == nil {
      cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "SearchResultCell")
    }
    let searchResult = searchResults[indexPath.row]
    cell.textLabel?.text = searchResult.name
    cell.detailTextLabel?.text = searchResult.location
    return cell
  }
}

// MARK: Tableview selection

extension SearchController {
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    if let delegate = delegate {
      let searchResult = searchResults[indexPath.row]
      delegate.selectedSearchResult(searchResult)
    }
    searchController.active = false
  }
}
