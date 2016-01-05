import RealmSwift

protocol GuideControllerDelegate: class {
  func categorySelected(category: Attraction.Category)
  func navigateInternally()
}

class GuideController: UITableViewController, SubController {
  struct TableCellIdentifiers {
    static let guideItemCell = "GuideItemCell"
    static let categoryCell = "CategoryCell"
    static let loadingCell = "LoadingCell"
  }
  
  var session: Session!
  var delegate: GuideControllerDelegate!
  
  var itemStack = [GuideItemHolder]()
  
  var backButton: UIButton!
  var titleLabel: UILabel!
  var downloadButton: UIButton!
  var loading = false
  
  var countryList = [Region]()
  var mapsObject: SKTMapsObject!
  var mapCountryList: [SKTPackage]!
  var currentContinent: SKTPackage!
  var mapMappings: [String: String]!
  var currentItem: GuideItem?
  var currentCountryId: String? {
    return session.currentCountry?.getId()
  }
  var currentCountryName: String? {
    return session.currentCountry?.getName()
  }
  var currentRegion: Region?
  var currentSection: GuideText?
  var guideSections = List<GuideText>()
  var currentCategoryDescriptions = List<GuideText>()
  var guideItemExpanded = false
  var guideITemCreatedAsExpanded = false
  var containerFrame: CGRect!
  
  var tableSections = [TableSection]()
  
  class TableSection {
    var title: String?
    var cellIdentifier: String
    var elements = [(String, String)]()
    var handler: (NSIndexPath -> ())?
    
    init(title: String? = nil, cellIdentifier: String, handler: (NSIndexPath -> ())?) {
      self.title = title
      self.cellIdentifier = cellIdentifier
      self.handler = handler
    }
  }
  
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

    downloadButton = UIButton(type: UIButtonType.System)
    downloadButton.setTitle("Download", forState: UIControlState.Normal)
    downloadButton.sizeToFit()
    downloadButton.addTarget(self, action: "openDownloadCity:", forControlEvents: .TouchUpInside)
    
    if currentSection == nil {
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
    }
    
    loadContent()
  }
  
  func navigateBack(sender: UIButton) {
    let stackItem = itemStack.removeLast()
    if stackItem.getId().hasPrefix("region-") {
      currentSection = nil
      session.currentSection = nil
      let region = Region.constructRegion()
      region.listing.item.id = stackItem.getId()
      region.listing.item.name = stackItem.getName()
      currentRegion = nil
      session.currentRegion = region
    }
    else if stackItem.getId().hasPrefix("text-") {
      currentSection = nil
      session.currentSection = stackItem as? GuideText
    }
    else {
      currentItem = nil
      currentRegion = nil
      session.currentRegion = nil
      currentSection = nil
      session.currentSection = nil
    }
    loadContent()
    delegate.navigateInternally()
  }
  
  func loadContent() {
    loading = true
    tableView.contentOffset = CGPoint(x: 0, y: 0)
    if let currentSection = session.currentSection {
      self.currentSection = currentSection
      currentItem = currentSection.item
      if currentSection.item.id == "null" {
        currentItem = currentSection.item
        tableView.reloadData()
      }
      else {
        loadGuideTextWithId(currentSection.item.id)
      }
    }
    else if let currentRegion = session.currentRegion {
      loadRegionWithID(currentRegion.listing.item.id)
    }
    else {
      loadCountryList()
    }
    
    if let currentSection = currentSection {
      let category = Attraction.Category(rawValue: currentSection.item.category)
      titleLabel.text = category?.entityName
    }
    if itemStack.count == 0 {
      backButton.hidden = true
      downloadButton.hidden = true
      titleLabel.text = "Countries"
    }
    else {
      backButton.hidden = false
      if let currentCountryId = currentCountryId {
        downloadButton.hidden = false
        if DownloadService.isRegionDownloaded(session.currentRegion!.getId(), countryId: currentCountryId) {
          downloadButton.setTitle("Downloaded", forState: .Normal)
        }
        else {
          downloadButton.setTitle("Download", forState: .Normal)
        }
      }
      let stackElement = itemStack.last!
      backButton.setTitle("< \(stackElement.getName())", forState: UIControlState.Normal)
      backButton.sizeToFit()
    }
    populateTableSections()
  }
  
  func openDownloadCity(sender: UIButton) {
    let nav = UINavigationController()
    let vc = DownloadController()
    vc.countryName = currentCountryName
    vc.countryId = currentCountryId
    vc.countryPackage = try! getMapPackageFromId(currentCountryId!)
    vc.regionName = session.currentRegion!.getName()
    vc.regionId = session.currentRegion!.getId()
    vc.regionPackage = try! getMapPackageFromId(session.currentRegion!.getId())
    if session.currentRegion!.mapCountry {
      vc.onlyMap = true
    }
    nav.viewControllers = [vc]
    view.window!.rootViewController!.presentViewController(nav, animated: true, completion: nil)
  }
  
  func getMapPackageFromId(regionId: String) throws -> SKTPackage {
    for (code, id) in mapMappings {
      if id == regionId {
        print("fetching package for code: \(code)")
        return mapsObject.packageForCode(code);
      }
    }
    throw Error.RuntimeError("No code found mapped to id: \(regionId)")
  }
  
  func loadCountryList() {
    var i = 0
    let populateTable = {
      i += 1
      if i == 2 {
        self.populateTableSections()
      }
    }
    ContentService.getCountries() {
      countries in
      
      self.countryList = countries
      self.loading = false
      populateTable()
      
    }
    if mapsObject == nil {
      session.mapVersionFileDownloaded.onComplete { _ in
        
        DownloadService.getMapsAvailable().onSuccess {
          (mapsObject, mappings) in
          
          
          self.mapMappings = mappings
          self.mapsObject = mapsObject
          populateTable()
        }
      }
    }
    else {
      populateTable()
    }
  }
  
  func getContinents() -> [SKTPackage] {
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
  
  func loadRegionWithID(regionId: String) {
    
    ContentService.getRegionWithId(regionId, failure: {
      
      print("Preparing for map country")
      self.currentRegion = self.session.currentRegion
      self.currentRegion!.listing.item.content = "This country has only map data."
      self.currentRegion!.mapCountry = true
      self.currentItem = self.currentRegion!.listing.item
      self.titleLabel.text = self.currentItem!.name
      self.loading = false
      self.populateTableSections()

      }) {
      region in
      
      self.currentRegion = region
      self.guideSections = region.listing.item.guideSections
      self.currentCategoryDescriptions = region.listing.item.categoryDescriptions
      self.currentItem = region.listing.item
      self.titleLabel.text = self.currentItem!.name
      self.session.currentRegion = region
      self.loading = false
      self.populateTableSections()
    }
  }
  
  func loadGuideTextWithId(guideTextId: String) {
    ContentService.getGuideTextWithId(currentRegion!, guideTextId: guideTextId) {
      guideText in
      
      self.currentSection = guideText
      self.guideSections = guideText.item.guideSections
      self.currentItem = guideText.item
      self.title = guideText.item.name
      self.loading = false
      self.populateTableSections()
    }
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
    
    if loading {
      let section = TableSection(cellIdentifier: TableCellIdentifiers.loadingCell, handler: nil)
      section.elements.append(("", ""))
      tableSections.append(section)
    }
    else if currentItem == nil {
      let section = TableSection(cellIdentifier: TableCellIdentifiers.categoryCell, handler: navigateToCountry)
      for country in countryList {
        section.elements.append((title: country.listing.item.name!, value: country.listing.item.id))
      }
      tableSections.append(section)
      
      let continents = TableSection(title: "Continents", cellIdentifier: TableCellIdentifiers.categoryCell, handler: navigateToContinent)
      for continent in getContinents() {
        continents.elements.append((title: continent.nameForLanguageCode("en"), value: ""))
      }
      tableSections.append(continents)
      
    }
    else if currentItem!.category > Region.Category.CONTINENT.rawValue {
      let section = TableSection(cellIdentifier: TableCellIdentifiers.guideItemCell, handler: nil)
      section.elements.append(("", ""))
      tableSections.append(section)
    }

    if guideItemExpanded {
      let section = TableSection(cellIdentifier: TableCellIdentifiers.categoryCell, handler: navigateToSection)
      for guideSection in guideSections {
        section.elements.append((title: guideSection.item.name!, value: guideSection.item.id))
      }
      tableSections.append(section)
    }

    if currentRegion != nil && !currentRegion!.mapCountry && currentSection == nil {
      var section = TableSection(cellIdentifier: TableCellIdentifiers.categoryCell, handler: navigateToCategory)
      let section2 = TableSection(title: "Directory", cellIdentifier: TableCellIdentifiers.categoryCell, handler: navigateToCategoryDescription)
      var i = 0
      for category in Attraction.Category.allValues {
        if i > 2 {
          section2.elements.append((title: category.entityName, value: String(category.rawValue)))
        }
        else if i > 0 {
          var name = category.entityName
          if name == "Explore the city" && currentRegion!.listing.item.category == Region.Category.COUNTRY.rawValue {
            name = "Explore the country"
          }
          else if name == "Explore the city" && currentRegion!.listing.item.category == Region.Category.CONTINENT.rawValue {
            name = "Explore the continent"
          }
          section.elements.append((title: name, value: String(category.rawValue)))
        }
        i += 1
      }
      tableSections.append(section)
      
      if (currentItem!.subRegions.count > 0) {
        switch currentItem!.category {
        case Region.Category.CONTINENT.rawValue:
          section = TableSection(title: "Countries:", cellIdentifier: TableCellIdentifiers.categoryCell, handler: navigateToCity)
        case Region.Category.COUNTRY.rawValue:
          section = TableSection(title: "Cities:", cellIdentifier: TableCellIdentifiers.categoryCell, handler: navigateToCity)
        default:
          section = TableSection(title: "Neighbourhoods:", cellIdentifier: TableCellIdentifiers.categoryCell, handler: navigateToCity)
        }
        for subRegion in currentItem!.subRegions {
          var itemName = subRegion.listing.item.name!
          let range = itemName.rangeOfString("/")
          if range != nil {
            itemName = itemName.substringFromIndex(range!.endIndex)
          }
          section.elements.append((title: itemName, value: subRegion.listing.item.id))
        }
        tableSections.append(section)
      }
      if currentRegion!.listing.item.category > Region.Category.CONTINENT.rawValue {
        tableSections.append(section2)        
      }
      else {
        let mapSection = TableSection(title: "Countries with only maps", cellIdentifier: TableCellIdentifiers.categoryCell, handler: navigateToMapCountry)
        print(currentContinent.mapsObject)
        let countryCandidates = currentContinent.childObjects() as! [SKTPackage]
        mapCountryList = [SKTPackage]()
        for countryCandidate in countryCandidates {
          let candidateName = countryCandidate.nameForLanguageCode("en")
          let candidateId = mapMappings[countryCandidate.packageCode]!
          var alreadyListed = false
          for country in countryList {
            if candidateId == country.getId() {
              alreadyListed = true
              break
            }
          }
          if !alreadyListed {
            mapSection.elements.append((title: candidateName, value: candidateId))
            mapCountryList.append(countryCandidate)
          }
        }
        tableSections.append(mapSection)
      }
    }
    else if currentSection != nil && currentSection?.item.category != 0 {
      let section = TableSection(cellIdentifier: TableCellIdentifiers.categoryCell, handler: nil)
      section.elements.append(("Browse", "browse"))
      tableSections.append(section)
    }
    
    tableView.reloadData()
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let section = tableSections[indexPath.section]
    let cell = tableView.dequeueReusableCellWithIdentifier(section.cellIdentifier, forIndexPath: indexPath)
    
    if let cell = cell as? GuideItemCell {
      cell.delegate = self
      cell.setContentFromGuideItem(currentItem!)
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
    tableView.reloadData()
  }
  
  func updateTableSize() {
    tableView.beginUpdates()
    tableView.endUpdates()
  }
}

// MARK: - Navigation
extension GuideController {

  func selectedSearchResult(searchResult: SearchResult) {
    ContentService.getRegionWithId(searchResult.listingId) {
      region in

      let doNav = {
        self.session.currentRegion = region
        self.loadContent()
        self.delegate.navigateInternally()
      }

      self.itemStack = [GuideItemHolder]()
      let allRegions = Region.constructRegion()
      allRegions.listing.item.name = "Continents"
      allRegions.listing.item.id = "top-level"
      self.itemStack.append(allRegions)
      if region.listing.item.category > Region.Category.COUNTRY.rawValue {
        ContentService.getRegionWithId(region.listing.country) {
          country in
          
          self.itemStack.append(country)
          if region.listing.item.category > Region.Category.CITY.rawValue {
            ContentService.getRegionWithId(region.listing.city) {
              city in
              
              self.itemStack.append(city)
              doNav()
            }
          }
          else {
            doNav()
          }
        }
      }
      else {
        doNav()
      }
    }
  }
  
  func navigateToContinent(indexPath: NSIndexPath) {
    let allRegions = Region.constructRegion()
    allRegions.listing.item.name = "Continents"
    allRegions.listing.item.id = "top-level"
    itemStack.append(allRegions)
    let continent = Region.constructRegion()
    let continentPackage = getContinents()[indexPath.row]
    let continentName = continentPackage.nameForLanguageCode("en")
    self.currentContinent = getContinents()[indexPath.row]
    continent.listing.item.name = continentName
    continent.listing.item.id = mapMappings[continentPackage.packageCode]
    session.currentRegion = continent
    loadContent()
    delegate.navigateInternally()
    
  }

  func navigateToCountry(indexPath: NSIndexPath) {
    let allRegions = Region.constructRegion()
    allRegions.listing.item.name = "Continents"
    allRegions.listing.item.id = "top-level"
    itemStack.append(allRegions)
    session.currentRegion = countryList[indexPath.row]
    loadContent()
    delegate.navigateInternally()
  }
  
  func navigateToMapCountry(indexPath: NSIndexPath) {
    itemStack.append(currentRegion!)
    let region = Region.constructRegion()
    let countryPackage = mapCountryList[indexPath.row]
    let countryName = countryPackage.nameForLanguageCode("en")
    let countryId = mapMappings[countryPackage.packageCode]
    region.listing.item.id = countryId
    region.listing.item.name = countryName
    region.listing.item.category = Region.Category.COUNTRY.rawValue
    session.currentRegion = region
    loadContent()
    delegate.navigateInternally()
  }


  func navigateToCity(indexPath: NSIndexPath) {
    itemStack.append(currentRegion!)
    session.currentRegion = currentRegion!.listing.item.subRegions[indexPath.row]
    loadContent()
    delegate.navigateInternally()
  }

  func navigateToSection(indexPath: NSIndexPath) {
    var current: GuideItemHolder = currentRegion!
    if let currentSection = currentSection {
      current = currentSection
    }
    session.currentSection = guideSections[indexPath.row]
    itemStack.append(current)
    loadContent()
    delegate.navigateInternally()
  }
  
  func navigateToCategoryDescription(indexPath: NSIndexPath) {
    var current: GuideItemHolder = currentRegion!
    if let currentSection = currentSection {
      current = currentSection
    }
    itemStack.append(current)
    session.currentSection = currentCategoryDescriptions[indexPath.row + 2]
    print(session.currentSection)
    loadContent()
    delegate.navigateInternally()
  }
  
  func navigateToCategory(indexPath: NSIndexPath) {
    if currentSection != nil {
      let category = Attraction.Category(rawValue: currentSection!.item.category)!
      delegate.categorySelected(category)
      
    }
    else {
      delegate.categorySelected(Attraction.Category.allValues[indexPath.row + 1])
    }
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    if let handler = tableSections[indexPath.section].handler {
      handler(indexPath)
    }
    
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
}
