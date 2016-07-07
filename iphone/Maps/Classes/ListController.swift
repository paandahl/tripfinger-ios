import Foundation
import Firebase

class ListController: GuideItemController {
  
  let displayGrouped: Bool
  let regionId: String
  let countryMwmId: String
  let regionLicense: String?
  let categoryDescription: GuideText
  var listings: [Listing]?
  weak var mapNavigator: MapNavigator!
  
  init(regionId: String, countryMwmId: String, grouped: Bool, categoryDescription: GuideText, regionLicense: String?, mapNavigator: MapNavigator) {
    self.regionId = regionId
    self.countryMwmId = countryMwmId
    self.regionLicense = regionLicense
    self.mapNavigator = mapNavigator
    self.displayGrouped = grouped
    self.categoryDescription = categoryDescription
    super.init(guideItem: categoryDescription.item)
    addObserver(DatabaseService.TFCountrySavedNotification, selector: #selector(countryDownloaded(_:)))    
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {

    view.backgroundColor = UIColor.whiteColor()
    super.viewDidLoad()
    if !displayGrouped {
      loadListings()
    } else {
      populateTableSections()
    }    
  }
  
  /*
  * Load attractions, and put the liked ones first
  */
  func loadListings() {
    listings = nil
    self.tableView.reloadData()
    let failure = { () -> () in
      self.delay(2, selector: #selector(self.loadListings))
    }
    let subCatValue = categoryDescription.item.subCategory
    let category = subCatValue != 0 ? subCatValue : categoryDescription.item.category
    ContentService.getCascadingListingsForRegion(regionId, withCategory: category, failure: failure) { listings in
      var likedListings = [Listing]()
      var notLikedListings = [Listing]()
      for attraction in listings {
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
  
  func selectedSearchResult(searchResult: SimplePOI, stopSpinner: () -> ()) {
  }
}

// MARK: - Table View Data Source
extension ListController {
  
  override func populateTableSections() {
    tableSections = [TableSection]()
    
    if categoryDescription.item.content != nil {
      let section = TableSection(title: "", cellIdentifier: TableCellIdentifiers.guideItemCell)
      section.elements.append((title: "", value: ""))
      tableSections.append(section)
    }
    
    if guideItemExpanded {
      let section = TableSection(cellIdentifier: TableCellIdentifiers.rightDetailCell, target: self, selector: #selector(navigateToSection))
      for guideSection in categoryDescription.item.guideSections {
        section.elements.append((title: guideSection.item.name, value: guideSection))
      }
      tableSections.append(section)
    }

    if displayGrouped {
      let section = TableSection(cellIdentifier: TableCellIdentifiers.rightDetailCell, target: self, selector: #selector(navigateToSubCategory))
      for subCatDesc in categoryDescription.item.categoryDescriptions {
        section.elements.append((title: "", value: subCatDesc))
      }
      tableSections.append(section)
    } else if let listings = listings {
      let liked = TableSection(title: "Listings", cellIdentifier: TableCellIdentifiers.likedCell)
      let notLiked = TableSection(title: "", cellIdentifier: TableCellIdentifiers.listingCell)
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
      let section = TableSection(title: "", cellIdentifier: TableCellIdentifiers.loadingCell)
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
    let listingsController = ListingsController(regionId: regionId, countryMwmId: countryMwmId, categoryDescription: subCatDesc, regionLicense: regionLicense, mapNavigator: mapNavigator)
    parentViewController!.navigationController!.pushViewController(listingsController, animated: true)
  }
  
  func navigateToSection(object: AnyObject) {
    let section = object as! GuideText
    let sectionController = SectionController(section: section, mapNavigator: mapNavigator)
    navigationController!.pushViewController(sectionController, animated: true)
    AnalyticsService.logSelectedSection(section)
  }

  func countryDownloaded(notification: NSNotification) {
    if tableView != nil {
      let countryName = notification.object as! String
      let country = DatabaseService.getCountry(countryName)!
      if country.getDownloadId() == countryMwmId {
        loadListings()
      }
    }
  }
}

extension ListController: ListingCellContainer {
  
  func showDetail(listing: Listing) {
    let entity = TripfingerEntity(listing: listing)
    MapsAppDelegateWrapper.openPlacePage(entity, withCountryMwmId: countryMwmId)
    AnalyticsService.logSelectedListing(listing)
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