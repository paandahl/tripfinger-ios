import Foundation

class ListController: UITableViewController {
  struct TableViewCellIdentifiers {
    static let listingCell = "ListingCell"
  }
  
  var session: Session
  var displayGrouped: Bool
  var category: Attraction.Category!
  var currentRegion: Region!
  
  init(session: Session, grouped: Bool) {
    self.session = session
    self.displayGrouped = grouped
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    UINib.registerNib(TableViewCellIdentifiers.listingCell, forTableView: tableView)
    
    category = session.currentCategory
    currentRegion = session.currentRegion

    tableView.tableHeaderView = UIView(frame: CGRectZero)
    
    if self.session.currentRegion != nil {
      loadAttractions()
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    if session.currentRegion != nil && (category != session.currentCategory || currentRegion != session.currentRegion) {
      category = session.currentCategory
      currentRegion = session.currentRegion
      loadAttractions()
    }
    updateLabels()
  }
  
  func updateLabels() {
  }
  
  func loadAttractions() {
    category = session.currentCategory
    session.loadAttractions {
      self.tableView.reloadData()
    }
  }
  
  override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showFilter" {
      let navigationController = segue.destinationViewController as! UINavigationController
      let filterController = navigationController.viewControllers[0] as! FilterController
      filterController.session = session
      filterController.delegate = self
    }
  }
  
  func selectedSearchResult(searchResult: SimplePOI, stopSpinner: () -> ()) {
  }
}

// MARK: - Table View Data Source
extension ListController {
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return session.currentAttractions.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.listingCell, forIndexPath: indexPath) as! ListingCell
    let attraction = session.currentAttractions[indexPath.row]
    cell.setContent(attraction)
    cell.delegate = self
    return cell
  }
}

extension ListController: ListingCellContainer {
  
  func showDetail(attraction: Attraction) {
    let vc = DetailController()
    vc.attraction = attraction
    self.navigationController!.pushViewController(vc, animated: true)
  }
}

extension ListController: FilterBoxDelegate {
  
  func filterClick() {
    performSegueWithIdentifier("showFilter", sender: nil)
  }
}

extension ListController: FilterControllerDelegate {
  
  func filterChanged() {
    dismissViewControllerAnimated(true, completion: nil)
    viewWillAppear(true)
  }
}