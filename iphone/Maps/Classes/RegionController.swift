import RealmSwift
import MBProgressHUD

protocol RegionControllerDelegate: class {
  func categorySelected(category: Listing.Category, view: String)
  func navigateInternally(callback: () -> ())
}

class RegionController: GuideItemController {
  
  var delegate: RegionControllerDelegate!
  let refreshControl = UIRefreshControl()
  var countryLists = [(String, List<Region>)]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let colorImage = UIImage(withColor: UIColor.primary(), frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 64))
    navigationController!.navigationBar.setBackgroundImage(colorImage, forBarMetrics: .Default)
    navigationController!.navigationBar.translucent = true
    
    if session.currentRegion == nil && countryLists.count == 0 {
      refreshControl.addTarget(self, action: "reffo", forControlEvents: .ValueChanged)
      tableView.addSubview(refreshControl)
      loadCountryLists()
    }
    updateUI()
    
    dispatch_async(dispatch_get_main_queue()) {
      MapsAppDelegateWrapper.getMapViewController().view.layoutSubviews()
    }
  }
  
  func reffo() {
    loadCountryLists()
  }
  
  override func updateUI() {
    print("UPDATEUI, main thread: \(NSThread.isMainThread())")
    // if nil, we are in offline mode, changeRegion returned immediately, and viewdidload will trigger this method
    if let tableView = tableView {
      if session.currentItem != nil {
        navigationItem.title = session.currentItem.name
      } else {
        navigationItem.title = "Countries"
      }
      
      populateTableSections()
      tableView.reloadData {
        self.tableView.contentOffset = CGPointZero
      }
    }
    refreshControl.endRefreshing()
  }
  
  override func downloadClicked() {
    if let mwmRegionId = session.currentCountry.mwmRegionId {
      MapsAppDelegateWrapper.openDownloads(mwmRegionId, navigationController: navigationController)
    } else {
      MapsAppDelegateWrapper.openDownloads(session.currentCountry.getName(), navigationController: navigationController)
    }
  }
  
  func loadCountryLists() {
    print("loading country lists")
    if NetworkUtil.connectedToNetwork() {
      let failure = { () -> () in
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(2), target: self, selector: "loadCountryLists", userInfo: nil, repeats: false)
      }
      ContentService.getCountries(failure) {
        countries in
        
        print("Fetched \(countries.count) countries.")
        for country in countries {
          country.item().loadStatus = GuideItem.LoadStatus.CHILDREN_NOT_LOADED
        }
        self.countryLists = self.makeCountryLists(countries)
        print("Turned \(countries.count) countries into \(self.countryLists.count) country lists.")
        self.updateUI()
      }
    } else {
      countryLists = makeCountryLists(Array<Region>(DatabaseService.getCountries()))
      updateUI()
    }
  }
  
  private func getCountryList(worldArea: String, countryLists: [(String, List<Region>)]) -> List<Region>? {
    for (area, countryList) in countryLists {
      if area == worldArea {
        return countryList
      }
    }
    return nil
  }
  
  private func makeCountryLists(countries: [Region]) -> [(String, List<Region>)] {
    var countryLists = [(String, List<Region>)]()
    var betaCountries = [(Region, List<Region>)]()
    for country in countries {
      var countryList = getCountryList(country.listing.worldArea, countryLists: countryLists)
      if countryList == nil {
        countryList = List<Region>()
        countryLists.append((country.listing.worldArea, countryList!))
      }
      if country.item().status == 0 {
        betaCountries.append((country, countryList!))
      } else {
        countryList!.append(country)
      }
    }
    for (country, list) in betaCountries {
      list.append(country)
    }
    return countryLists
  }  
}

// MARK: - Table data source
extension RegionController {
  
  override func populateTableSections() {
    tableSections = [TableSection]()
    
    if session.currentItem == nil {
      if !NetworkUtil.connectedToNetwork() && countryLists.count == 0 {
        let section = TableSection(cellIdentifier: TableCellIdentifiers.textMessageCell, handler: nil)
        section.elements.append((title: "", value: ""))
        tableSections.append(section)
      } else {
        for (regionName, countryList) in countryLists {
          let section = TableSection(title: regionName, cellIdentifier: TableCellIdentifiers.rightDetailCell, handler: navigateToRegion)
          for country in countryList {
            section.elements.append((title: country.listing.item.name!, value: country))
          }
          tableSections.append(section)
        }
      }
    } else if session.currentItem.category > Region.Category.CONTINENT.rawValue {
      let section = TableSection(cellIdentifier: TableCellIdentifiers.guideItemCell, handler: nil)
      section.elements.append(("", ""))
      tableSections.append(section)
    }
    
    if guideItemExpanded {
      let section = TableSection(cellIdentifier: TableCellIdentifiers.rightDetailCell, handler: navigateToSection)
      for guideSection in session.currentItem.guideSections {
        section.elements.append((title: guideSection.item.name, value: guideSection))
      }
      tableSections.append(section)
    }
    
    if session.currentRegion != nil {
      var section = TableSection(cellIdentifier: TableCellIdentifiers.rightDetailCell, handler: navigateToCategory)
      let section2 = TableSection(title: "Directory", cellIdentifier: TableCellIdentifiers.rightDetailCell, handler: navigateToCategory)
      var i = 0
      for categoryDesc in session.currentRegion.item().allCategoryDescriptions {
        let category = Listing.Category(rawValue: categoryDesc.item.category)!
        if i > 0 {
          section2.elements.append((title: category.entityName, value: categoryDesc))
        } else {
          section.elements.append((title: category.entityName, value: categoryDesc))
        }
        i += 1
      }
      tableSections.append(section)
      
      if session.currentRegion.item().subRegions.count > 0 {
        switch session.currentRegion.item().category {
        case Region.Category.CONTINENT.rawValue:
          section = TableSection(title: "Countries:", cellIdentifier: TableCellIdentifiers.rightDetailCell, handler: navigateToRegion)
        case Region.Category.COUNTRY.rawValue:
          section = TableSection(title: "Destinations:", cellIdentifier: TableCellIdentifiers.rightDetailCell, handler: navigateToRegion)
        case Region.Category.SUB_REGION.rawValue:
          section = TableSection(title: "Destinations:", cellIdentifier: TableCellIdentifiers.rightDetailCell, handler: navigateToRegion)
        default:
          section = TableSection(title: "Neighbourhoods:", cellIdentifier: TableCellIdentifiers.rightDetailCell, handler: navigateToRegion)
        }
        
        for subRegion in session.currentRegion.item().subRegions {
          var itemName = subRegion.listing.item.name
          let range = itemName.rangeOfString("/")
          if range != nil {
            itemName = itemName.substringFromIndex(range!.endIndex)
          }
          section.elements.append((title: itemName, value: subRegion))
        }
        tableSections.append(section)
      }
      tableSections.append(section2)
    }
  }
    
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let section = tableSections[indexPath.section]
    if section.cellIdentifier == TableCellIdentifiers.guideItemCell {
      let cell = GuideItemCell()
      cell.delegate = self
      cell.setContentFromGuideItem(session.currentItem)
      if (guideItemExpanded) {
        cell.expand()
      }
      cell.setNeedsUpdateConstraints()
      return cell
      
    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier(section.cellIdentifier, forIndexPath: indexPath)
      if let cell = cell as? TextMessageCell {
        cell.setTextMessage("You are offline. Go online to view and download countries.")
      } else if cell.reuseIdentifier == TableCellIdentifiers.loadingCell {
        let indicator = cell.viewWithTag(1000) as! UIActivityIndicatorView
        indicator.startAnimating()
      } else if let cell = cell as? RightDetailCell where indexPath.row < section.elements.count {
        cell.textLabel!.text = section.elements[indexPath.row].0
        if let region = section.elements[indexPath.row].1 as? Region {
          cell.unfinishedLabel.hidden = region.item().status == 1
        }
      } else {
        // this is just for the application not to hang when we have race conditions
        // f.ex. you navigate to a region, the cell count is calculated, but before
        // rendering starts, the table is re-populated because the fetch finished fast.
        // in these cases we return empty cells, since a re-render is under way
        return UITableViewCell()
      }
      
      return cell
    }
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let title = tableSections[section].title
    if session.currentRegion == nil && title != nil && !title!.containsString("Unfinished") {
      let view = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 160))
      let libPath = NSURL.getDirectory(.LibraryDirectory)
      let imagePath = libPath.URLByAppendingPathComponent(title! + ".jpeg")
      let image = UIImageView(frame: CGRectMake(0, 0, tableView.frame.size.width, 150))
      image.contentMode = .ScaleAspectFill
      image.clipsToBounds = true
      if NSURL.fileExists(imagePath) {
        image.image = UIImage(data: NSData(contentsOfURL: imagePath)!)
      } else {
        var imageUrl = DownloadService.gcsImagesUrl + title! + ".jpeg"
        imageUrl = imageUrl.stringByReplacingOccurrencesOfString(" ", withString: "%20")
        NetworkUtil.saveDataFromUrl(imageUrl, destinationPath: imagePath) {
          image.image = UIImage(data: NSData(contentsOfURL: imagePath)!)
        }
      }
      let label = UILabel(frame: CGRectMake(10, 120, tableView.frame.size.width, 18))
      label.font = UIFont.boldSystemFontOfSize(18)
      label.textColor = UIColor.lightGrayColor()
      label.shadowColor = UIColor.blackColor()
      label.shadowOffset = CGSizeMake(0, 1)
      label.layer.shadowOpacity = 0.5
      let string = tableSections[section].title
      label.text = string
      view.addSubview(image)
      view.addSubview(label)
      return view;
    } else {
      return nil
    }
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if session.currentRegion == nil && !tableSections[section].title!.containsString("Unfinished") {
      return 160
    } else {
      return 0
    }
  }
}

// MARK: - Navigation
extension RegionController {
  
  func navigateToRegion(object: AnyObject) {
    guideItemExpanded = false
    let region = object as! Region
    
    let regionController = RegionController.constructRegionController(session)
    navigationController!.pushViewController(regionController, animated: true)
    
    session.changeRegion(region, failure: navigationFailure) {
      regionController.updateUI()
    }
  }
    
  func navigateToCategory(object: AnyObject) {
    let categoryDescription = object as! GuideText
    session.currentCategory = Listing.Category(rawValue: categoryDescription.item.category)!
    print("set curent category to: \(session.currentCategory)")
    
    let listingsController = ListingsController(session: session, categoryDescription: categoryDescription)
    listingsController.edgesForExtendedLayout = .None // offset from navigation bar
    navigationController!.pushViewController(listingsController, animated: true)
    session.changeSection(categoryDescription, failure: navigationFailure) {
      listingsController.updateUI()
    }
  }
    
  class func constructRegionController(session: Session, title: String? = nil) -> RegionController {
    let regionController = RegionController(session: session)
    regionController.edgesForExtendedLayout = .None // offset from navigation bar
    regionController.navigationItem.title = title
    return regionController
  }
  
  //extension RootController: SearchViewControllerDelegate {
  //  func selectedSearchResult(searchResult: SimplePOI) {
  //    dismissViewControllerAnimated(true, completion: nil)
  //
  //    if searchResult.category == 180 { // street
  //      if !(currentController is MapController) {
  //        navigateToSubview("mapController", controllerType: MapController.self)
  //      }
  //    }
  //    else if String(searchResult.category).hasPrefix("2") { // Listing
  //      if !(currentController is MapController) {
  //        navigateToSubview("mapController", controllerType: MapController.self)
  //      }
  //    }
  //    let subController = currentController as! SubController
  //    subController.selectedSearchResult(searchResult)
  //  }
  //}  
}
