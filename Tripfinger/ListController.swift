import Foundation

class ListController: UITableViewController {
  struct TableCellIdentifiers {
    static let guideItemCell = "GuideItemCell"
    static let listingCell = "ListingCell"
    static let likedCell = "LikedListingCell"
    static let loadingCell = "LoadingCell"
    static let rightDetailCell = "RightDetailCell"
  }
  
  let session: Session
  let searchDelegate: SearchViewControllerDelegate
  let displayGrouped: Bool
  let categoryDescription: GuideText
  var attractionsList: [Attraction]?
  
  init(session: Session, searchDelegate: SearchViewControllerDelegate, grouped: Bool, categoryDescription: GuideText) {
    self.session = session
    self.searchDelegate = searchDelegate
    self.displayGrouped = grouped
    self.categoryDescription = categoryDescription
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  override func viewDidLoad() {
    UINib.registerClass(RightDetailCell.self, reuseIdentifier: TableCellIdentifiers.rightDetailCell, forTableView: tableView)
    UINib.registerClass(GuideItemCell.self, reuseIdentifier: TableCellIdentifiers.guideItemCell, forTableView: tableView)
    UINib.registerClass(ListingCell.self, reuseIdentifier: TableCellIdentifiers.listingCell, forTableView: tableView)
    UINib.registerClass(ListingCell.self, reuseIdentifier: TableCellIdentifiers.likedCell, forTableView: tableView)
    UINib.registerNib(TableCellIdentifiers.loadingCell, forTableView: tableView)

    tableView.tableHeaderView = UIView(frame: CGRectZero)

    if !displayGrouped && session.currentRegion != nil {
      loadAttractions()
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    if !displayGrouped {
      loadAttractions()
    }
    updateLabels()
  }
  
  func updateLabels() {
  }
  
  func loadDescription() {
  }
  
  func loadSubCategoryList() {
    self.tableView.reloadData()
  }
  
  /*
  * Load attractions, and put the liked ones first
  */
  func loadAttractions() {
    attractionsList = nil
    self.tableView.reloadData()
    session.loadAttractions {
      
      var likedAttractions = [Attraction]()
      var notLikedAttractions = [Attraction]()
      for attraction in self.session.currentAttractions {
        if attraction.listing.notes?.likedState == GuideListingNotes.LikedState.LIKED {
          likedAttractions.append(attraction)
        }
        else {
          notLikedAttractions.append(attraction)
        }
      }
      var attractionsList = [Attraction]()
      attractionsList.appendContentsOf(likedAttractions)
      attractionsList.appendContentsOf(notLikedAttractions)
      self.attractionsList = attractionsList

      SyncManager.run_async {
        dispatch_async(dispatch_get_main_queue()) {
          self.tableView.reloadData()
        }
      }
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
    var count: Int
    if displayGrouped {
      count = categoryDescription.item.guideSections.count
    } else if let attractionsList = attractionsList {
      count = attractionsList.count
    } else {
      count = 1
    }
    if categoryDescription.item.content != nil {
      count = count + 1
    }    
    return count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let index = categoryDescription.item.content != nil ? indexPath.row - 1 : indexPath.row
    if categoryDescription.item.content != nil && indexPath.row == 0 {
      let cell = tableView.dequeueReusableCellWithIdentifier(TableCellIdentifiers.guideItemCell) as! GuideItemCell
      cell.setContentFromGuideItem(categoryDescription.item)
      return cell
    }
    
    if displayGrouped {
      let cell = tableView.dequeueReusableCellWithIdentifier(TableCellIdentifiers.rightDetailCell, forIndexPath: indexPath)
      print("index: \(index)")
      let subCatId = categoryDescription.item.guideSections[index].item.subCategory
      print("subCatId: \(subCatId)")
      let subCat = Attraction.SubCategory(rawValue: subCatId)!
      cell.textLabel!.text = subCat.entityName
      return cell
      
    } else if let attractionsList = attractionsList {
      let attraction = attractionsList[index]
      let cell: ListingCell!
      if let notes = attraction.listing.notes where notes.likedState == GuideListingNotes.LikedState.LIKED {
        cell = tableView.dequeueReusableCellWithIdentifier(TableCellIdentifiers.likedCell, forIndexPath: indexPath) as! ListingCell
      } else {
        cell = tableView.dequeueReusableCellWithIdentifier(TableCellIdentifiers.listingCell, forIndexPath: indexPath) as! ListingCell
      }
      cell.setContent(attraction)
      cell.delegate = self
      return cell
    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier(TableCellIdentifiers.loadingCell, forIndexPath: indexPath)
      let activityIndicator = cell.viewWithTag(1000) as! UIActivityIndicatorView
      activityIndicator.startAnimating()
      return cell
    }
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if displayGrouped {
      let index = categoryDescription.item.content != nil ? indexPath.row - 1 : indexPath.row
      let subcategoryDescription = categoryDescription.item.guideSections[index]
      session.currentSubCategory = Attraction.SubCategory(rawValue: subcategoryDescription.item.subCategory)!
      
      let attractionsController = AttractionsController(session: session, searchDelegate: searchDelegate, categoryDescription: subcategoryDescription)
      attractionsController.edgesForExtendedLayout = .None // offset from navigation bar
      navigationController!.pushViewController(attractionsController, animated: true)
    }
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