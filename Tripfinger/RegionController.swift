import RealmSwift

protocol RegionControllerDelegate: class {
  func categorySelected(category: Attraction.Category, view: String)
  func navigateInternally(callback: () -> ())
}

class RegionController: GuideItemController {
  
  var delegate: RegionControllerDelegate!
  var countryLists = [String: [Region]]()
  
  init(session: Session) {
    super.init(session: session, searchDelegate: nil)
    self.searchDelegate = self
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    automaticallyAdjustsScrollViewInsets = false
    let mapButton = UIBarButtonItem(image: UIImage(named: "maps_icon"), style: .Plain, target: self, action: "navigateToMap")
    mapButton.accessibilityLabel = "Map"
    let searchButton = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "navigateToSearch")
    navigationItem.rightBarButtonItems = [searchButton, mapButton]
        
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 44.0;
    tableView.tableHeaderView = UIView.init(frame: CGRectMake(0.0, 0.0, tableView.bounds.size.width, 0.01))
    tableView.tableFooterView = UIView.init(frame: CGRectZero)
        
    if session.currentRegion == nil && countryLists.count == 0 {
      loadCountryLists()      
    }
    updateUI()
  }
  
  override func updateUI() {
    // if nil, we are in offline mode, changeRegion returned immediately, and viewdidload will trigger this method
    if let tableView = tableView {
      if session.currentItem != nil {
        navigationItem.title = session.currentItem.name
      }
      else {
        navigationItem.title = "Countries"
      }
      
      populateTableSections()
      tableView.reloadData {
        self.tableView.contentOffset = CGPointZero
      }
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    print("view will dissappear")
    if let navigationController = navigationController where
      navigationController.viewControllers.indexOf(self) == nil && !contextSwitched {
      print("moving back in hierarchy")
      guideItemExpanded = false
      let parentRegionController = navigationController.viewControllers.last as! RegionController
      session.moveBackInHierarchy {
        print("new currentREgion: \(self.session.currentRegion?.getName())")
        if parentRegionController.tableSections.count == 0 {
          parentRegionController.updateUI()          
        }
      }
    }
  }
  
  override func downloadClicked() {
    let nav = UINavigationController()
    let vc = DownloadController()
    vc.country = session.currentCountry
    vc.city = session.currentCity
    nav.viewControllers = [vc]
    view.window!.rootViewController!.presentViewController(nav, animated: true, completion: nil)
  }
  
  func loadCountryLists() {
    print("loading country lists")
    if NetworkUtil.connectedToNetwork() {
      ContentService.getCountries() {
        countries in
        
        for country in countries {
          country.item().loadStatus = GuideItem.LoadStatus.CHILDREN_NOT_LOADED
        }
        self.countryLists = RegionController.makeCountryDict(countries)
        self.updateUI()
      }
    } else {
      self.countryLists = RegionController.makeCountryDict(Array<Region>(DatabaseService.getCountries()))
      self.updateUI()
    }
  }
  
  class func makeCountryDict(countries: [Region]) -> [String: [Region]] {
    var countryDict = [String: [Region]]()
    var betaList = [Region]()
    for country in countries {
      if country.item().status == 0 {
        betaList.append(country)
      }
      else {
        var countryList = countryDict[country.listing.worldArea]
        if countryList == nil {
          countryList = [Region]()
        }
        countryList!.append(country)
        countryDict[country.listing.worldArea] = countryList        
      }
    }
    if betaList.count > 0 {
      countryDict["Beta"] = betaList
    }
    return countryDict
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
        let attractionsSection = TableSection(title: "Wordwide", cellIdentifier: TableCellIdentifiers.rightDetailCell, handler: navigateToCategory)
        let guideText = GuideText()
        guideText.item = GuideItem()
        guideText.item.category = Attraction.Category.ATTRACTIONS.rawValue
        attractionsSection.elements.append((title: "Attractions", value: guideText))
        tableSections.append(attractionsSection)
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
        let category = Attraction.Category(rawValue: categoryDesc.item.category)!
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
          section = TableSection(title: "Cities:", cellIdentifier: TableCellIdentifiers.rightDetailCell, handler: navigateToRegion)
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
    let cell = tableView.dequeueReusableCellWithIdentifier(section.cellIdentifier, forIndexPath: indexPath)
    
    if let cell = cell as? GuideItemCell {
      cell.delegate = self
      cell.setContentFromGuideItem(session.currentItem)
      if (guideItemExpanded) {
        cell.expand()
      }
      cell.setNeedsUpdateConstraints()
      
    } else if let cell = cell as? TextMessageCell {
      cell.setTextMessage("You are offline. Go online to view and download countries.")
      
    } else if cell.reuseIdentifier == TableCellIdentifiers.loadingCell {
      let indicator = cell.viewWithTag(1000) as! UIActivityIndicatorView
      indicator.startAnimating()
    } else {
      cell.textLabel!.text = section.elements[indexPath.row].0
    }
    
    return cell
  }
}

// MARK: - Navigation
extension RegionController: SearchViewControllerDelegate {
  
  func navigateToRegion(object: AnyObject) {
    guideItemExpanded = false
    let region = object as! Region
    
    let regionController = constructRegionController()
    navigationController!.pushViewController(regionController, animated: true)
    
    session.changeRegion(region) {
      regionController.updateUI()
    }
  }
    
  func navigateToCategory(object: AnyObject) {
    let categoryDescription = object as! GuideText
    session.currentCategory = Attraction.Category(rawValue: categoryDescription.item.category)!
    print("set curent category to: \(session.currentCategory)")
    
    let listingsController = ListingsController(session: session, searchDelegate: self, categoryDescription: categoryDescription)
    listingsController.edgesForExtendedLayout = .None // offset from navigation bar
    navigationController!.pushViewController(listingsController, animated: true)
    session.changeSection(categoryDescription) {
      listingsController.updateUI()
    }
  }
  
  func selectedSearchResult(searchResult: SimplePOI, stopSpinner: () -> ()) {
    session.loadRegionFromSearchResult(searchResult) {
      stopSpinner()
      self.dismissViewControllerAnimated(true) {
        let nav = self.navigationController!
        for viewController in nav.viewControllers {
          if let regionController = viewController as? RegionController {
            regionController.contextSwitched = true
          }
        }
        nav.popToRootViewControllerAnimated(false)
        let currentListing = self.session.currentRegion.listing
        var viewControllers = [nav.viewControllers.first!]
        if self.session.currentRegion.item().category > Region.Category.COUNTRY.rawValue {
          viewControllers.append(self.constructRegionController(currentListing.country))
        }
        if self.session.currentRegion.item().category > Region.Category.SUB_REGION.rawValue {
          if self.session.currentRegion.listing.subRegion != nil {
            viewControllers.append(self.constructRegionController(currentListing.subRegion))
          }
        }
        if self.session.currentRegion.item().category > Region.Category.CITY.rawValue {
          viewControllers.append(self.constructRegionController(currentListing.city))
        }
        viewControllers.append(self.constructRegionController())
        nav.setViewControllers(viewControllers, animated: true)
      }
    }
  }
  
  private func constructRegionController(title: String? = nil) -> RegionController {
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
  //    else if String(searchResult.category).hasPrefix("2") { // Attraction
  //      if !(currentController is MapController) {
  //        navigateToSubview("mapController", controllerType: MapController.self)
  //      }
  //    }
  //    let subController = currentController as! SubController
  //    subController.selectedSearchResult(searchResult)
  //  }
  //}  
}
