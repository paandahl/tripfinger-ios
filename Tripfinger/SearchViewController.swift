import Foundation

protocol SearchViewControllerDelegate: class {
    func selectedSearchResult(searchResult: SearchResult)
}

class SearchViewController: UITableViewController {

    var delegate: SearchViewControllerDelegate?
    var searchService: SearchService!
    var searchController: UISearchController!
    var searchBarItem: UIBarButtonItem!
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

extension SearchViewController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let newSearchText = searchController.searchBar.text!
        if (newSearchText.characters.count > 1 && newSearchText != searchText) {
            
            searchText = newSearchText
            searchService.cancelSearch()
            
            searchService.search(searchText) {
                searchResults in
                
                self.searchResults = searchResults
                self.tableView.reloadData()
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

extension SearchViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchResultCell", forIndexPath: indexPath)
        let searchResult = searchResults[indexPath.row]
        cell.textLabel?.text = searchResult.name
        cell.detailTextLabel?.text = searchResult.city
        return cell
    }
}

// MARK: Tableview selection

extension SearchViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let delegate = delegate {
            let searchResult = searchResults[indexPath.row]
            delegate.selectedSearchResult(searchResult)
        }
        searchController.active = false
    }
}
