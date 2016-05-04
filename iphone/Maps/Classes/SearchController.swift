import Foundation
import RealmSwift
import MBProgressHUD

protocol SearchViewControllerDelegate: class {
  func selectedSearchResult(searchResult: SimplePOI, failure: () -> (), stopSpinner: () -> ())
}

class SearchController: UITableViewController {
  
  var regionId: String?
  var countryId: String?
  
  var delegate: SearchViewControllerDelegate
  var searchService: SearchService!
  var searchBar: UISearchBar!
  
  var searchResults = [SimplePOI]()
  var lastSearchText = ""

  init(delegate: SearchViewControllerDelegate, regionId: String?, countryId: String?) {
    self.delegate = delegate
    self.regionId = regionId
    self.countryId = countryId
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let colorImage = UIImage(withColor: UIColor.primary(), frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 64))
    navigationController!.navigationBar.setBackgroundImage(colorImage, forBarMetrics: .Default)
    navigationController!.navigationBar.translucent = true

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
    self.navigationItem.titleView!.tintColor = UIColor.darkGrayColor()

    self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: backButton)
  }
  
  override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask.Portrait
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
      
      lastSearchText = searchText
      searchService.cancelSearch()
      searchService.search(searchText) { results in
        print("searchResults received in controller: \(results.count)")
        self.searchResults = results
        self.tableView.reloadData()
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
    if searchResult.category == Region.Category.COUNTRY.rawValue {
      cell.detailTextLabel!.text = "Country"
    }
    else {
      cell.detailTextLabel?.text = searchResult.location      
    }
    return cell
  }
}

// MARK: Tableview selection

extension SearchController {
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    loadingNotification.mode = MBProgressHUDMode.Indeterminate
    loadingNotification.labelText = "Loading"
    
    let searchResult = searchResults[indexPath.row]
    let failure = {
      MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
      let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
      loadingNotification.mode = MBProgressHUDMode.CustomView
      loadingNotification.labelText = "Connection failed"
      let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
      dispatch_after(delayTime, dispatch_get_main_queue()) {
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
      }
    }
    delegate.selectedSearchResult(searchResult, failure: failure) {
      self.searchBar.resignFirstResponder()
      tableView.deselectRowAtIndexPath(indexPath, animated: true)
      MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
    }
  }
}
