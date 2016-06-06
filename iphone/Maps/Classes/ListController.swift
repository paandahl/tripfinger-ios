import Foundation

class ListController: GuideItemController {
  
  let displayGrouped: Bool
  let categoryDescription: GuideText
  var listings: [Listing]?
  
  init(session: Session, grouped: Bool, categoryDescription: GuideText) {
    self.displayGrouped = grouped
    self.categoryDescription = categoryDescription
    super.init(session: session)
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {

    super.viewDidLoad()
    if !displayGrouped && session.currentRegion != nil {
      loadListings()
    } else {
      populateTableSections()
    }
    
    print("arriving at ListController sectionStack had: \(session.sectionStack.count)")
  }
  
  /*
  * Load attractions, and put the liked ones first
  */
  func loadListings() {
    listings = nil
    self.tableView.reloadData()
    let failure = { () -> () in
      NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(2), target: self, selector: #selector(ListController.loadListings), userInfo: nil, repeats: false)
    }
    session.loadListings(failure) {
      
      var likedListings = [Listing]()
      var notLikedListings = [Listing]()
      for attraction in self.session.currentListings {
        if attraction.listing.notes?.likedState == GuideListingNotes.LikedState.LIKED {
          likedListings.append(attraction)
        }
        else {
          notLikedListings.append(attraction)
        }
      }
      var listings = [Listing]()
      listings.appendContentsOf(likedListings)
      listings.appendContentsOf(notLikedListings)
      self.listings = listings

      SyncManager.run_async {
        dispatch_async(dispatch_get_main_queue()) {
          self.populateTableSections()
          self.tableView.reloadData()
        }
      }
    }
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
  
  override func populateTableSections() {
    tableSections = [TableSection]()
    
    if categoryDescription.item.content != nil {
      let section = TableSection(title: "", cellIdentifier: TableCellIdentifiers.guideItemCell, handler: nil)
      section.elements.append((title: "", value: ""))
      tableSections.append(section)
    }
    
    if guideItemExpanded {
      let section = TableSection(cellIdentifier: TableCellIdentifiers.rightDetailCell, handler: navigateToSection)
      for guideSection in session.currentItem.guideSections {
        section.elements.append((title: guideSection.item.name, value: guideSection))
      }
      print("displaying guideSections for \(session.currentItem.name): \(session.currentItem.guideSections)")
      tableSections.append(section)
    }

    if displayGrouped {
      let section = TableSection(title: "", cellIdentifier: TableCellIdentifiers.rightDetailCell, handler: navigateToSubCategory)
      for subCatDesc in categoryDescription.item.categoryDescriptions {
        section.elements.append((title: "", value: subCatDesc))
      }
      print("displayedGroup, added \(section.elements.count)")
      tableSections.append(section)
    } else if let listings = listings {
      print("listings")
      let liked = TableSection(title: "Listings", cellIdentifier: TableCellIdentifiers.likedCell, handler: nil)
      let notLiked = TableSection(title: "", cellIdentifier: TableCellIdentifiers.listingCell, handler: nil)
      for listing in listings {
        if let notes = listing.listing.notes where notes.likedState == GuideListingNotes.LikedState.LIKED {
          liked.elements.append((title: "", value: listing))
        } else {
          notLiked.elements.append((title: "", value: listing))
        }
      }
      print(liked.elements.count)
      print(notLiked.elements.count)
      tableSections.append(liked)
      tableSections.append(notLiked)
    } else {
      let section = TableSection(title: "", cellIdentifier: TableCellIdentifiers.loadingCell, handler: nil)
      section.elements.append((title: "", value: ""))
      tableSections.append(section)
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let section = tableSections[indexPath.section]
    if section.cellIdentifier == TableCellIdentifiers.guideItemCell {
      let cell = GuideItemCell()
      cell.delegate = self
      cell.setContentFromGuideItem(categoryDescription.item)
      if (guideItemExpanded) {
        cell.expand()
      }
      cell.setNeedsUpdateConstraints()
      return cell
      
    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier(section.cellIdentifier, forIndexPath: indexPath)
      if let cell = cell as? RightDetailCell {
        let subSection = section.elements[indexPath.row].1 as! GuideText
        if subSection.item.subCategory == 0 {
          cell.textLabel!.text = subSection.item.name
        } else {
          let subCat = Listing.SubCategory(rawValue: subSection.item.subCategory)!
          cell.textLabel!.text = subCat.entityName
        }
      } else if let cell = cell as? ListingCell {
        let attraction = section.elements[indexPath.row].1 as! Listing
        cell.setContent(attraction)
        cell.delegate = self
        
      } else {
        let activityIndicator = cell.viewWithTag(1000) as! UIActivityIndicatorView
        activityIndicator.startAnimating()
      }
      return cell
    }
  }
  
  func navigateToSubCategory(object: AnyObject) {
    let subCatDesc = object as! GuideText
    session.currentSubCategory = Listing.SubCategory(rawValue: subCatDesc.item.subCategory)!
    let listingsController = ListingsController(session: session, categoryDescription: subCatDesc)
    listingsController.edgesForExtendedLayout = .None // offset from navigation bar
    print("parentView: \(parentViewController)")
    parentViewController!.navigationController!.pushViewController(listingsController, animated: true)
    session.changeSection(subCatDesc, failure: navigationFailure) { _ in
      listingsController.updateUI()
    }
  }
  
  override func viewWillDisappear(animated: Bool) {}
  
  func parentViewWillDisappear(viewController: UIViewController) {
    if let navigationController = navigationController where
      navigationController.viewControllers.indexOf(viewController) == nil && !contextSwitched {
        if categoryDescription.item.subCategory != 0 {
          session.currentSubCategory = nil
        } else {
          session.currentCategory = Listing.Category.ATTRACTIONS
        }
    }
    super.backButtonAction(viewController)
  }
}

extension ListController: ListingCellContainer {
  
  func showDetail(listing: Listing) {
    self.session.currentListing = listing
    let entity = TripfingerEntity(listing: listing)
    MapsAppDelegateWrapper.openPlacePage(entity)
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