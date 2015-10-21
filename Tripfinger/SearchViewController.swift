import Foundation

class SearchViewController: UITableViewController {

    var searchService: SearchService!
    var searchController: UISearchController!
    var searchBarItem: UIBarButtonItem!
    var searchResults = [SKSearchResult]()

    override func viewDidLoad() {
        super.viewDidLoad()
        searchService = SearchService()
        
//        let searchBar:UISearchBar = UISearchBar(frame: CGRectMake(0, 0, 200, 20))
//        let searchBarItem = UIBarButtonItem(customView: searchBar)
//        self.navigationItem.leftBarButtonItem = searchBarItem;
//        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.active = true
        
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


extension SearchViewController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text!
        if (searchText.characters.count > 1) {
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
}

extension SearchViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchResultCell", forIndexPath: indexPath)
        let searchResult = searchResults[indexPath.row]
        cell.textLabel?.text = searchResult.name
        cell.detailTextLabel?.text = String(searchResult.coordinate.latitude)
        return cell
    }
}
