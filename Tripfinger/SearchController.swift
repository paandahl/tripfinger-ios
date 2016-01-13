import Foundation
import RealmSwift

protocol SearchViewControllerDelegate: class {
  func selectedSearchResult(searchResult: SimplePOI)
}

class SearchController: UITableViewController {
  
  var regionId: String?
  var countryId: String?
  
  var delegate: SearchViewControllerDelegate?
  var searchService: SearchService!
  var searchBar: UISearchBar!
  
  var offlineResults = [SimplePOI]()
  var onlineResults = List<SimplePOI>()
  var searchResults = [SimplePOI]()
  var lastSearchText = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    searchService = SearchService()
    
    // Include the search controller's search bar within the table's header view.
    searchBar = UISearchBar()
    searchBar.becomeFirstResponder()
    searchBar.delegate = self
    let backButton = UIButton(type: UIButtonType.System)
    backButton.addTarget(self, action: "closeSearch", forControlEvents: .TouchUpInside)
    backButton.setTitle("Cancel", forState: UIControlState.Normal)
    backButton.sizeToFit()
    self.navigationItem.titleView = searchBar
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: backButton)
  }
  
  func closeSearch() {
    searchBar.resignFirstResponder()
    dismissViewControllerAnimated(true, completion: nil)
  }
}

// MARK: - Search controller functionality

extension SearchController: UISearchBarDelegate {
  
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    if (searchText.characters.count > 1 && searchText != lastSearchText) {
      
      self.offlineResults = [SimplePOI]()
      lastSearchText = searchText
      
      if NetworkUtil.connectedToNetwork() {
        searchService.onlineSearch(searchText, regionId: regionId, countryId: countryId, gradual: true) {
          searchResults in
          
          self.onlineResults = searchResults
          self.searchResults = [SimplePOI]()
          self.searchResults.appendContentsOf(self.onlineResults)
          self.searchResults.appendContentsOf(self.offlineResults)
          self.tableView.reloadData()
        }
      }
      searchService.offlineSearch(searchText, regionId: regionId, countryId: countryId) {
        city, searchResults, nextCityHandler in
        
        self.offlineResults.appendContentsOf(searchResults)
        self.searchResults = [SimplePOI]()
        self.searchResults.appendContentsOf(self.onlineResults)
        self.searchResults.appendContentsOf(self.offlineResults)
        self.tableView.reloadData()
        if let nextCityHandler = nextCityHandler {
          nextCityHandler()
        }
      }
    }
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
    searchBar.resignFirstResponder()
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    if let delegate = delegate {
      let searchResult = searchResults[indexPath.row]
      delegate.selectedSearchResult(searchResult)
    }
  }
}
