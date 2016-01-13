import RealmSwift

protocol GuideControllerDelegate: class {
  func categorySelected(category: Attraction.Category, view: String)
  func navigateInternally(callback: () -> ())
}

class GuideController: UITableViewController, SubController {
  struct TableCellIdentifiers {
    static let guideItemCell = "GuideItemCell"
    static let categoryCell = "CategoryCell"
    static let loadingCell = "LoadingCell"
  }
  
  var session: Session!
  var delegate: GuideControllerDelegate!
  
  var backButton: UIButton!
  var titleLabel: UILabel!
  var downloadButton: UIButton!
  
  var countryList = [Region]()
  var mapsObject: SKTMapsObject!
  var mapCountryList: [SKTPackage]!
  
  var guideItemExpanded = false
  var guideITemCreatedAsExpanded = false
  var containerFrame: CGRect!
  
  var tableSections = [TableSection]()
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    automaticallyAdjustsScrollViewInsets = false
    
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 44.0;
    tableView.tableHeaderView = UIView.init(frame: CGRectZero)
    tableView.tableFooterView = UIView.init(frame: CGRectZero)
    
    UINib.registerClass(GuideItemCell.self, reuseIdentifier: TableCellIdentifiers.guideItemCell, forTableView: tableView)
    UINib.registerNib(TableCellIdentifiers.categoryCell, forTableView: tableView)
    UINib.registerNib(TableCellIdentifiers.loadingCell, forTableView: tableView)
    
    backButton = UIButton(type: UIButtonType.System)
    backButton.addTarget(self, action: "navigateBack:", forControlEvents: .TouchUpInside)
    
    titleLabel = UILabel(frame: CGRectMake(10, 5, tableView.frame.size.width, 18))
    titleLabel.font = UIFont.boldSystemFontOfSize(16)
    
    downloadButton = UIButton(type: .System)
    downloadButton.addTarget(self, action: "openDownloadCity:", forControlEvents: .TouchUpInside)
    
    let headerView = UIView()
    headerView.addSubview(titleLabel)
    headerView.addSubview(downloadButton)
    headerView.addSubview(backButton)
    headerView.addConstraints("V:|-10-[title(22)]", forViews: ["title": titleLabel])
    headerView.addConstraints("V:|-10-[download(22)]", forViews: ["download": downloadButton])
    headerView.addConstraints("V:|-10-[back(22)]", forViews: ["back": backButton])
    headerView.addConstraints("H:|-15-[back]", forViews: ["back": backButton])
    headerView.addConstraint(NSLayoutAttribute.CenterX, forView: titleLabel)
    headerView.addConstraints("H:[download]-15-|", forViews: ["download": downloadButton])
    var headerFrame = headerView.frame;
    headerFrame.size.height = 44;
    headerView.frame = headerFrame;
    tableView.tableHeaderView = headerView
    
    loadCountryList()
    updateUI()
  }
  
  func updateUI() {
    // title label
    if session.currentItem != nil {
      titleLabel.text = session.currentItem.name
    }
    else {
      titleLabel.text = "Countries"
    }
    
    // back button
    var backElementName = ""
    if session.currentSection != nil {
      backElementName = session.previousSection != nil ? session.previousSection.getName() : session.currentRegion.getName()
      backButton.hidden = false
    }
    else if session.currentRegion != nil && session.currentRegion.item().category != 0 {
      backElementName = session.currentRegion.listing.getParentName()
      backButton.hidden = false
    }
    else {
      backButton.hidden = true
    }
    backButton.setTitle("< \(backElementName)", forState: .Normal)
    backButton.sizeToFit()
    
    // download button
    if session.currentSection == nil && session.currentRegion != nil {
      switch session.currentItem.category {
      case Region.Category.CITY.rawValue:
        fallthrough
      case Region.Category.COUNTRY.rawValue:
        let downloaded = DownloadService.isRegionDownloaded(mapsObject, country: session.currentCountry, city: session.currentCity)
        let title = downloaded ? "Downloaded" : "Download"
        downloadButton.setTitle(title, forState: .Normal)
        downloadButton.hidden = false
      default:
        downloadButton.hidden = true
      }
    }
    else {
      downloadButton.hidden = true
    }
    
    populateTableSections()
    tableView.reloadData {
      self.tableView.contentOffset = CGPointZero
    }
  }
  
  func navigateBack(sender: UIButton) {
    session.moveBackInHierarchy {
      self.updateUI()
    }
    delegate.navigateInternally {
      self.updateUI()
    }
  }
  
  func openDownloadCity(sender: UIButton) {
    let nav = UINavigationController()
    let vc = DownloadController()
    vc.mapsObject = mapsObject
    vc.country = session.currentCountry
    vc.city = session.currentCity
    if session.currentRegion.mapCountry {
      vc.onlyMap = true
    }
    nav.viewControllers = [vc]
    view.window!.rootViewController!.presentViewController(nav, animated: true, completion: nil)
  }
  
  func loadCountryList() {
    var i = 0
    let populateTable = {
      i += 1
      if i == 2 {
        self.populateTableSections()
        self.updateUI()
      }
    }
    ContentService.getCountries() {
      countries in
      
      for country in countries {
        country.item().contentLoaded = false
      }
      self.countryList = countries
      populateTable()
      
    }
    if mapsObject == nil {
      session.mapVersionFileDownloaded.onComplete { _ in
        
        DownloadService.getMapsAvailable().onSuccess {
          mapsObject in
          
          self.mapsObject = mapsObject
          populateTable()
        }
      }
    }
    else {
      populateTable()
    }
  }
  
  func getContinentMapPackages() -> [SKTPackage] {
    var continents = [SKTPackage]()
    let allContinents = mapsObject.packagesForType(.Continent) as! [SKTPackage]
    for continent in allContinents {
      if continent.nameForLanguageCode("en") != "Antarctica" {
        continent.mapsObject = mapsObject
        continents.append(continent)
      }
    }
    return continents
  }
  
}

// MARK: - Table data source
extension GuideController {
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return tableSections.count;
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return tableSections[section].elements.count;
  }
  
  func populateTableSections() {
    tableSections = [TableSection]()
    
    if self.mapsObject == nil ||
      (session.currentRegion != nil && !session.currentRegion.item().contentLoaded && session.currentSection == nil) {
        let section = TableSection(cellIdentifier: TableCellIdentifiers.loadingCell, handler: nil)
        section.elements.append(("", ""))
        tableSections.append(section)
    }
    else {
      if session.currentItem == nil {
        if mapsObject != nil {
          let section = TableSection(cellIdentifier: TableCellIdentifiers.categoryCell, handler: navigateToRegion)
          for country in countryList {
            section.elements.append((title: country.listing.item.name!, value: country))
          }
          tableSections.append(section)
          
          let continents = TableSection(title: "Continents", cellIdentifier: TableCellIdentifiers.categoryCell, handler: navigateToRegion)
          for continent in getContinentMapPackages() {
            let continentName = continent.nameForLanguageCode("en")
            let continentRegion = Region.constructRegion(continentName)
            continents.elements.append((title: continentName, value: continentRegion))
          }
          tableSections.append(continents)
        }
      }
      else if (session.currentSection == nil && session.currentItem.category > Region.Category.CONTINENT.rawValue) || (session.currentSection != nil && session.currentSection.item.content != nil) {
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
          }
          else {
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
        if session.currentRegion.listing.item.category > Region.Category.CONTINENT.rawValue {
          tableSections.append(section2)
        }
        else {
          let mapSection = TableSection(title: "Countries with only maps", cellIdentifier: TableCellIdentifiers.categoryCell, handler: navigateToRegion)
          let continentName = session.currentContinent.getName()
          let countryCandidates = try! mapsObject.getMapPackage(continentName, type: .Continent).childObjects() as! [SKTPackage]
          mapCountryList = [SKTPackage]()
          for countryCandidate in countryCandidates {
            let candidateName = countryCandidate.nameForLanguageCode("en")
            var alreadyListed = false
            for country in countryList {
              if candidateName == country.getName() {
                alreadyListed = true
                break
              }
            }
            if !alreadyListed {
              let countryRegion = Region.constructRegion(candidateName, continent: session.currentContinent.getName())
              countryRegion.mapCountry = true
              countryRegion.item().contentLoaded = true
              countryRegion.item().content = "This country has only map data."
              mapSection.elements.append((title: candidateName, value: countryRegion))
              mapCountryList.append(countryCandidate)
            }
          }
          tableSections.append(mapSection)
        }
      }
      else if session.currentSection != nil && session.currentSection.item.category != 0 {
        let section = TableSection(cellIdentifier: TableCellIdentifiers.categoryCell, handler: navigateToCategory)
        section.elements.append(("Swipe", "swipe"))
        section.elements.append(("List", "list"))
        section.elements.append(("Map", "map"))
        tableSections.append(section)
      }
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
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if let title = tableSections[section].title {
      return title
    }
    else {
      return nil
    }
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
extension GuideController {
  
  func selectedSearchResult(searchResult: SimplePOI) {
    session.loadRegionFromSearchResult(searchResult) {
      self.updateUI()
    }
    self.updateUI()
  }
  
  func navigateToRegion(object: AnyObject) {
    let region = object as! Region
    
    session.changeRegion(region) {
      self.updateUI()
    }
    
    delegate.navigateInternally {
      self.updateUI()
    }
  }
  
  func navigateToSection(object: AnyObject) {
    let section = object as! GuideText
    
    session.changeSection(section) {
      self.updateUI()
    }
    
    delegate.navigateInternally {
      self.updateUI()
    }    
  }
  
  func navigateToCategory(object: AnyObject) {
    let view = object as! String
    delegate.categorySelected(Attraction.Category(rawValue: session.currentItem.category)!, view: view)
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    let section = tableSections[indexPath.section];
    if let handler = section.handler {
      handler(section.elements[indexPath.row].1)
    }
    
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
}