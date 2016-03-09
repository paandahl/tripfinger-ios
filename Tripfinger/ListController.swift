import Foundation

class ListController: TableController {
  
  let searchDelegate: SearchViewControllerDelegate
  let displayGrouped: Bool
  let categoryDescription: GuideText
  var listings: [Attraction]?
  var guideItemExpanded = false
  
  init(session: Session, searchDelegate: SearchViewControllerDelegate, grouped: Bool, categoryDescription: GuideText) {
    self.searchDelegate = searchDelegate
    self.displayGrouped = grouped
    self.categoryDescription = categoryDescription
    super.init(session: session)
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 44.0;
    tableView.tableHeaderView = UIView.init(frame: CGRectMake(0.0, 0.0, tableView.bounds.size.width, 0.01))
    tableView.tableFooterView = UIView.init(frame: CGRectZero)

    if !displayGrouped && session.currentRegion != nil {
      loadAttractions()
    } else {
      populateTableSections()
    }
  }
  
  func loadDescription() {
  }
  
  /*
  * Load attractions, and put the liked ones first
  */
  func loadAttractions() {
    listings = nil
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
      self.listings = attractionsList

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
  
  func populateTableSections() {
    tableSections = [TableSection]()
    
    if categoryDescription.item.content != nil {
      let section = TableSection(title: "", cellIdentifier: TableCellIdentifiers.guideItemCell, handler: nil)
      section.elements.append((title: "", value: ""))
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
    let cell = tableView.dequeueReusableCellWithIdentifier(section.cellIdentifier, forIndexPath: indexPath)
    print("begging for cell: \(section.cellIdentifier)")

    if let cell = cell as? GuideItemCell {
      cell.delegate = self
      cell.setContentFromGuideItem(categoryDescription.item)
      if (guideItemExpanded) {
        cell.expand()
      }
      cell.setNeedsUpdateConstraints()
      return cell
      
    } else if let cell = cell as? RightDetailCell {
      let subCatDesc = section.elements[indexPath.row].1 as! GuideText
      let subCatId =  subCatDesc.item.subCategory
      let subCat = Attraction.SubCategory(rawValue: subCatId)!
      cell.textLabel!.text = subCat.entityName
      return cell
      
    } else if let cell = cell as? ListingCell {
      let attraction = section.elements[indexPath.row].1 as! Attraction
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
  
  func navigateToSubCategory(object: AnyObject) {
    let subcategoryDescription = object as! GuideText
    session.currentSubCategory = Attraction.SubCategory(rawValue: subcategoryDescription.item.subCategory)!
    
    let attractionsController = AttractionsController(session: session, searchDelegate: searchDelegate, categoryDescription: subcategoryDescription)
    attractionsController.edgesForExtendedLayout = .None // offset from navigation bar
    navigationController!.pushViewController(attractionsController, animated: true)
  }
}

extension ListController: GuideItemContainerDelegate {
  
  func readMoreClicked() {
    guideItemExpanded = true
    populateTableSections()
    tableView.reloadData()
  }
  
  func downloadClicked() {}
}


extension ListController: ListingCellContainer {
  
  func showDetail(attraction: Attraction) {
    let vc = DetailController(session: session, searchDelegate: searchDelegate)
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