import Foundation

class ListController: GuideItemController {
  
  let displayGrouped: Bool
  let categoryDescription: GuideText
  var listings: [Listing]?
  
  init(session: Session, searchDelegate: SearchViewControllerDelegate, grouped: Bool, categoryDescription: GuideText) {
    self.displayGrouped = grouped
    self.categoryDescription = categoryDescription
    super.init(session: session, searchDelegate: searchDelegate)
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
    session.loadListings {
      
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
      let section = TableSection(title: "", cellIdentifier: TableCellIdentifiers.rightDetailCell, handler: navigateToSubSection)
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
    let cell = tableView.dequeueReusableCellWithIdentifier(section.cellIdentifier, forIndexPath: indexPath)

    if let cell = cell as? GuideItemCell {
      cell.delegate = self
      cell.setContentFromGuideItem(categoryDescription.item)
      if (guideItemExpanded) {
        cell.expand()
      }
      cell.setNeedsUpdateConstraints()
      return cell
      
    } else if let cell = cell as? RightDetailCell {
      let subSection = section.elements[indexPath.row].1 as! GuideText
      if subSection.item.subCategory == 0 {
        cell.textLabel!.text = subSection.item.name
      } else {
        let subCat = Listing.SubCategory(rawValue: subSection.item.subCategory)!
        cell.textLabel!.text = subCat.entityName
      }
      return cell
    } else if let cell = cell as? ListingCell {
      let attraction = section.elements[indexPath.row].1 as! Listing
      cell.setContent(attraction)
      cell.delegate = self
      print("returning listing cell")
      return cell
      
    } else {
      let activityIndicator = cell.viewWithTag(1000) as! UIActivityIndicatorView
      activityIndicator.startAnimating()
      return cell
    }
  }
  
  func navigateToSubSection(object: AnyObject) {
    let subSection = object as! GuideText
    if subSection.item.subCategory == 0 {
      session.currentSubCategory = Listing.SubCategory(rawValue: subSection.item.subCategory)!
      let listingsController = ListingsController(session: session, searchDelegate: searchDelegate, categoryDescription: subSection)
      listingsController.edgesForExtendedLayout = .None // offset from navigation bar
      navigationController!.pushViewController(listingsController, animated: true)
      session.changeSection(subSection) {
        listingsController.updateUI()
      }
    } else {
      navigateToSection(object)
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
    let vc = DetailController(session: session, searchDelegate: searchDelegate)
    vc.listing = listing
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