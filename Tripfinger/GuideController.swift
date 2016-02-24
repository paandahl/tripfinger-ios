import RealmSwift

protocol GuideControllerDelegate: class {
  func categorySelected(category: Attraction.Category, view: String)
  func navigateInternally(callback: () -> ())
}

class GuideController: UITableViewController, SubController {
  struct TableCellIdentifiers {
    static let guideItemCell = "GuideItemCell"
    static let textMessageCell = "TextMessageCell"
    static let categoryCell = "CategoryCell"
    static let loadingCell = "LoadingCell"
  }
  
  var contextSwitched = false
  var session: Session!
  var delegate: GuideControllerDelegate!
  
  let downloadButton = UIButton(type: .System)

  var countryLists = [String: [Region]]()
  
  var guideItemExpanded = false
  var containerFrame: CGRect!
  
  var tableSections = [TableSection]()
    
  override func viewDidLoad() {
    super.viewDidLoad()

    automaticallyAdjustsScrollViewInsets = false
    let mapButton = UIBarButtonItem(image: UIImage(named: "maps_icon"), style: .Plain, target: self, action: nil)
    let searchButton = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "search")
    navigationItem.rightBarButtonItems = [searchButton, mapButton]
        
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 44.0;
    tableView.tableHeaderView = UIView.init(frame: CGRectMake(0.0, 0.0, tableView.bounds.size.width, 0.01))
    tableView.tableFooterView = UIView.init(frame: CGRectZero)
    
    UINib.registerClass(GuideItemCell.self, reuseIdentifier: TableCellIdentifiers.guideItemCell, forTableView: tableView)
    UINib.registerClass(TextMessageCell.self, reuseIdentifier: TableCellIdentifiers.textMessageCell, forTableView: tableView)
    UINib.registerNib(TableCellIdentifiers.categoryCell, forTableView: tableView)
    UINib.registerNib(TableCellIdentifiers.loadingCell, forTableView: tableView)
    
    downloadButton.addTarget(self, action: "openDownloadCity:", forControlEvents: .TouchUpInside)
    
    if session.currentRegion == nil && countryLists.count == 0 {
      loadCountryLists()      
    }
    updateUI()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
  }
  
  func updateUI() {
    // title label
    if session.currentItem != nil {
      navigationItem.title = session.currentItem.name
    }
    else {
      navigationItem.title = "Countries"
    }
    
    // download button
    if session.currentSection == nil && session.currentRegion != nil && session.currentItem.category == Region.Category.COUNTRY.rawValue {
      let downloaded = DownloadService.isCountryDownloaded(session.currentRegion)
      let title = downloaded ? "Downloaded" : "Download"
      downloadButton.setTitle(title, forState: .Normal)
      downloadButton.hidden = false
    } else {
      downloadButton.hidden = true
    }
    
    populateTableSections()
    tableView.reloadData {
      self.tableView.contentOffset = CGPointZero
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    print("VIEW WILL APPEAR!")
  }
  
  override func viewWillDisappear(animated: Bool) {
    print("view will dissappear")
    if let navigationController = navigationController where
      navigationController.viewControllers.indexOf(self) == nil && !contextSwitched {
      print("moving back in hierarchy")
      guideItemExpanded = false
      let parentGuideController = navigationController.viewControllers.last as! GuideController
      session.moveBackInHierarchy {
        print("new currentREgion: \(self.session.currentRegion?.getName())")
        parentGuideController.updateUI()
      }
    }
  }
  
  func openDownloadCity(sender: UIButton) {
    let nav = UINavigationController()
    let vc = DownloadController()
    vc.country = session.currentCountry
    vc.city = session.currentCity
    if session.currentRegion.mapCountry {
      vc.onlyMap = true
    }
    nav.viewControllers = [vc]
    view.window!.rootViewController!.presentViewController(nav, animated: true, completion: nil)
  }
  
  func loadCountryLists() {
    if NetworkUtil.connectedToNetwork() {
      ContentService.getCountries() {
        countries in
        
        for country in countries {
          country.item().loadStatus = GuideItem.LoadStatus.CHILDREN_NOT_LOADED
        }
        self.countryLists = GuideController.makeCountryMap(countries)
        self.updateUI()
      }
    } else {
      self.countryLists = GuideController.makeCountryMap(Array<Region>(DatabaseService.getCountries()))
      self.updateUI()
    }
  }
  
  class func makeCountryMap(countries: [Region]) -> [String: [Region]] {
    var countryMap = [String: [Region]]()
    var betaList = [Region]()
    for country in countries {
      if country.item().status == 0 {
        betaList.append(country)
      }
      else {
        var countryList = countryMap[country.listing.worldArea]
        if countryList == nil {
          countryList = [Region]()
        }
        countryList!.append(country)
        countryMap[country.listing.worldArea] = countryList        
      }
    }
    if betaList.count > 0 {
      countryMap["Beta"] = betaList
    }
    return countryMap
  }  
}

// MARK: - Table data source
extension GuideController {
  
  func populateTableSections() {
    tableSections = [TableSection]()
    
    if session.currentItem == nil {
      if !NetworkUtil.connectedToNetwork() && countryLists.count == 0 {
        let section = TableSection(cellIdentifier: TableCellIdentifiers.textMessageCell, handler: nil)
        section.elements.append((title: "", value: ""))
        tableSections.append(section)
      }
      else {
        for (regionName, countryList) in countryLists {
          let section = TableSection(title: regionName, cellIdentifier: TableCellIdentifiers.categoryCell, handler: navigateToRegion)
          for country in countryList {
            section.elements.append((title: country.listing.item.name!, value: country))
          }
          tableSections.append(section)
        }
      }
    } else if (session.currentSection == nil && session.currentItem.category > Region.Category.CONTINENT.rawValue) || (session.currentSection != nil && session.currentSection.item.content != nil) {
      let section = TableSection(cellIdentifier: TableCellIdentifiers.guideItemCell, handler: nil)
      section.elements.append(("", ""))
      tableSections.append(section)
    }
    
    if guideItemExpanded {
      let section = TableSection(cellIdentifier: TableCellIdentifiers.categoryCell, handler: navigateToSection)
      
      for guideSection in session.currentItem.guideSections {
        section.elements.append((title: guideSection.item.name, value: guideSection))
      }
      tableSections.append(section)
    }
    
    if session.currentRegion != nil && !session.currentRegion.mapCountry && session.currentSection == nil {
      var section = TableSection(cellIdentifier: TableCellIdentifiers.categoryCell, handler: navigateToSection)
      let section2 = TableSection(title: "Directory", cellIdentifier: TableCellIdentifiers.categoryCell, handler: navigateToSection)
      var i = 0
      for categoryDesc in session.currentRegion.item().categoryDescriptions {
        if i > 1 {
          section2.elements.append((title: categoryDesc.getName(), value: categoryDesc))
        } else {
          section.elements.append((title: categoryDesc.getName(), value: categoryDesc))
        }
        i += 1
      }
      tableSections.append(section)
      
      if session.currentRegion.item().subRegions.count > 0 {
        switch session.currentRegion.item().category {
        case Region.Category.CONTINENT.rawValue:
          section = TableSection(title: "Countries:", cellIdentifier: TableCellIdentifiers.categoryCell, handler: navigateToRegion)
        case Region.Category.COUNTRY.rawValue:
          section = TableSection(title: "Destinations:", cellIdentifier: TableCellIdentifiers.categoryCell, handler: navigateToRegion)
        case Region.Category.SUB_REGION.rawValue:
          section = TableSection(title: "Cities:", cellIdentifier: TableCellIdentifiers.categoryCell, handler: navigateToRegion)
        default:
          section = TableSection(title: "Neighbourhoods:", cellIdentifier: TableCellIdentifiers.categoryCell, handler: navigateToRegion)
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
    else if session.currentSection != nil && session.currentSection.item.category != 0 {
      let section = TableSection(cellIdentifier: TableCellIdentifiers.categoryCell, handler: navigateToCategory)
      section.elements.append(("Swipe", "swipe"))
      section.elements.append(("List", "list"))
      section.elements.append(("Map", "map"))
      tableSections.append(section)
    }
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return tableSections.count;
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tableSections[section].elements.count;
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if let title = tableSections[section].title {
      return title
    }
    else {
      return nil
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let section = tableSections[indexPath.section]
    if section.cellIdentifier == TableCellIdentifiers.guideItemCell {
      print("Constructing guideItemCell")
    }
    let cell = tableView.dequeueReusableCellWithIdentifier(section.cellIdentifier, forIndexPath: indexPath)
    
    if let cell = cell as? GuideItemCell {
      cell.delegate = self
      cell.setContentFromGuideItem(session.currentItem)
      if (guideItemExpanded) {
        cell.expand()
      }
      cell.setNeedsUpdateConstraints()
    }
    else if let cell = cell as? TextMessageCell {
      print("setting textmessagecell")
      cell.setTextMessage("You are offline. Go online to view and download countries.")
    }
    else if cell.reuseIdentifier == TableCellIdentifiers.loadingCell {
      let indicator = cell.viewWithTag(1000) as! UIActivityIndicatorView
      indicator.startAnimating()
    }
    else {
      cell.textLabel?.text = section.elements[indexPath.row].0
    }
    
    return cell
  }
}


extension GuideController: GuideItemContainerDelegate {
  
  func readMoreClicked() {
    guideItemExpanded = true
    populateTableSections()
    tableView.reloadData()
  }
  
  func updateTableSize() {
    tableView.beginUpdates()
    tableView.endUpdates()
  }
}

// MARK: - Navigation
extension GuideController: SearchViewControllerDelegate {
  
  func navigateToRegion(object: AnyObject) {
    guideItemExpanded = false
    let region = object as! Region
    
    let guideController = GuideController(style: .Grouped)
    guideController.session = session
    guideController.edgesForExtendedLayout = .None // offset from navigation bar
    navigationController!.pushViewController(guideController, animated: true)
    
    session.changeRegion(region) {
      guideController.updateUI()
    }
  }
  
  func navigateToSection(object: AnyObject) {
    let section = object as! GuideText
    
    let guideController = GuideController(style: .Grouped)
    guideController.session = session
    guideController.edgesForExtendedLayout = .None // offset from navigation bar
    guideController.guideItemExpanded = true
    navigationController!.pushViewController(guideController, animated: true)
    
    session.changeSection(section) {
      guideController.updateUI()
    }
  }
  
  func navigateToCategory(object: AnyObject) {
    let view = object as! String
    delegate.categorySelected(Attraction.Category(rawValue: session.currentItem.category)!, view: view)
  }
  
  func search() {
    let nav = UINavigationController()
    let searchController = SearchController()
    searchController.delegate = self
    searchController.regionId = session.currentRegion?.getId()
    searchController.countryId = session.currentCountry?.getId()
    nav.viewControllers = [searchController]
    presentViewController(nav, animated: true, completion: nil)
  }
  
  func selectedSearchResult(searchResult: SimplePOI, stopSpinner: () -> ()) {
    session.loadRegionFromSearchResult(searchResult) {
      stopSpinner()
      print("before: \(self.navigationController!.viewControllers)")
      self.dismissViewControllerAnimated(true) {
        let nav = self.navigationController!
        for viewController in nav.viewControllers {
          if let guideController = viewController as? GuideController {
            guideController.contextSwitched = true
          }
        }
        nav.popToRootViewControllerAnimated(false)
        var viewControllers = [nav.viewControllers.first!]
        if self.session.currentRegion.item().category > Region.Category.COUNTRY.rawValue {
          let guideController = GuideController(style: .Grouped)
          guideController.session = self.session
          guideController.edgesForExtendedLayout = .None // offset from navigation bar
          guideController.navigationItem.title = self.session.currentRegion.listing.country
          viewControllers.append(guideController)
        }
        if self.session.currentRegion.item().category > Region.Category.SUB_REGION.rawValue {
          if self.session.currentRegion.listing.subRegion != nil {
            let guideController = GuideController(style: .Grouped)
            guideController.session = self.session
            guideController.edgesForExtendedLayout = .None // offset from navigation bar
            guideController.navigationItem.title = self.session.currentRegion.listing.subRegion
            viewControllers.append(guideController)
          }
        }
        if self.session.currentRegion.item().category > Region.Category.CITY.rawValue {
          let guideController = GuideController(style: .Grouped)
          guideController.session = self.session
          guideController.edgesForExtendedLayout = .None // offset from navigation bar
          guideController.navigationItem.title = self.session.currentRegion.listing.city
          viewControllers.append(guideController)
        }
        let guideController = GuideController(style: .Grouped)
        guideController.session = self.session
        guideController.edgesForExtendedLayout = .None // offset from navigation bar
        viewControllers.append(guideController)
        nav.setViewControllers(viewControllers, animated: true)
      }
    }
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    let section = tableSections[indexPath.section];
    if let handler = section.handler {
      handler(section.elements[indexPath.row].1)
    }
    
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
}
