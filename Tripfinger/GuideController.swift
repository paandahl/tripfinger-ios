import RealmSwift

protocol GuideControllerDelegate: class {
  func categorySelected(category: Attraction.Category)
  func navigateInternally()
}

class GuideController: UITableViewController, SubController {
  struct TableViewCellIdentifiers {
    static let guideItemCell = "GuideItemCell"
    static let categoryCell = "CategoryCell"
    static let textChildCell = "TextChild"
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
  var currentItem: GuideItem?
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
    
    init(title: String?, cellIdentifier: String, handler: (NSIndexPath -> ())?) {
      self.title = title
      self.cellIdentifier = cellIdentifier
      self.handler = handler
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.automaticallyAdjustsScrollViewInsets = false
    
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.tableHeaderView = UIView.init(frame: CGRectZero)
    tableView.tableFooterView = UIView.init(frame: CGRectZero)
    
    
    UINib.registerClass(GuideItemCell.self, reuseIdentifier: TableViewCellIdentifiers.guideItemCell, forTableView: tableView)
    UINib.registerNib(TableViewCellIdentifiers.categoryCell, forTableView: tableView)
    UINib.registerNib(TableViewCellIdentifiers.textChildCell, forTableView: tableView)
    UINib.registerNib(TableViewCellIdentifiers.loadingCell, forTableView: tableView)

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
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;

    loadContent()
  }
  
  func navigateBack(sender: UIButton) {
    let stackItem = itemStack.removeLast()
    if stackItem.getId().hasPrefix("region-") {
      print("Setting currentSection to nil")
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
      self.currentItem = currentSection.item
      if currentSection.item.id == "null" {
        self.currentItem = currentSection.item
        self.tableView.reloadData()
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
      downloadButton.hidden = false
      let stackElement = itemStack.last!
      backButton.setTitle("< \(stackElement.getName())", forState: UIControlState.Normal)
      backButton.sizeToFit()
    }
    populateTableSections()
  }
  
  func openDownloadCity(sender: UIButton) {
    let nav = UINavigationController()
    let vc = DownloadController()
    nav.viewControllers = [vc]
    presentViewController(nav, animated: true, completion: nil)
  }
  
  func loadCountryList() {
    ContentService.getCountries() {
      countries in
      
      self.countryList = countries
      self.loading = false
      self.populateTableSections()
    }
  }
  
  func loadRegionWithID(regionId: String) {
    
    ContentService.getRegionWithId(regionId) {
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

  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//    if section == 1 && !guideItemExpanded {
//      return 1
//    }
//    else {
//      return super.tableView(tableView, heightForHeaderInSection: section)
//    }
    
    return super.tableView(tableView, heightForHeaderInSection: section)
  }
  
  override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//    if section == 0 && !guideItemExpanded {
//      return 1
//    }
//    else {
//      return super.tableView(tableView, heightForHeaderInSection: section)
//    }
    
    return super.tableView(tableView, heightForHeaderInSection: section)
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
      let section = TableSection(title: nil, cellIdentifier: TableViewCellIdentifiers.loadingCell, handler: nil)
      section.elements.append(("", ""))
      tableSections.append(section)
    }
    else if currentItem == nil {
      let section = TableSection(title: nil, cellIdentifier: TableViewCellIdentifiers.categoryCell, handler: navigateToCountry)
      for country in countryList {
        section.elements.append((title: country.listing.item.name!, value: country.listing.item.id))
      }
      tableSections.append(section)
    }
    else {
      let section = TableSection(title: nil, cellIdentifier: TableViewCellIdentifiers.guideItemCell, handler: nil)
      section.elements.append(("", ""))
      tableSections.append(section)
    }

    if guideItemExpanded {
      let section = TableSection(title: nil, cellIdentifier: TableViewCellIdentifiers.categoryCell, handler: navigateToSection)
      for guideSection in guideSections {
        section.elements.append((title: guideSection.item.name!, value: guideSection.item.id))
      }
      tableSections.append(section)
    }

    if currentRegion != nil && currentSection == nil {
      var section = TableSection(title: nil, cellIdentifier: TableViewCellIdentifiers.categoryCell, handler: navigateToCategory)
      let section2 = TableSection(title: "Directory", cellIdentifier: TableViewCellIdentifiers.categoryCell, handler: navigateToCategoryDescription)
      var i = 0
      for category in Attraction.Category.allValues {
        if i > 2 {
          section2.elements.append((title: category.entityName, value: String(category.rawValue)))
        }
        else if i > 0 {
          var name = category.entityName
          if name == "Explore the city" && currentRegion?.listing.item.category == 130 {
            name = "Explore the country"
          }
          section.elements.append((title: name, value: String(category.rawValue)))
        }
        i += 1
      }
      tableSections.append(section)
      
      if (currentItem!.subRegions.count > 0) {
        switch currentItem!.category {
        case Region.Category.COUNTRY.rawValue:
          section = TableSection(title: "Cities:", cellIdentifier: TableViewCellIdentifiers.categoryCell, handler: navigateToCity)
        default:
          section = TableSection(title: "Neighbourhoods:", cellIdentifier: TableViewCellIdentifiers.categoryCell, handler: navigateToCity)
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
      tableSections.append(section2)
      
      
    }
    else if currentSection != nil && currentSection?.item.category != 0 {
      let section = TableSection(title: nil, cellIdentifier: TableViewCellIdentifiers.categoryCell, handler: nil)
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
    else if cell.reuseIdentifier == TableViewCellIdentifiers.loadingCell {
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
  
  func navigateToCountry(indexPath: NSIndexPath) {
    let allRegions = Region.constructRegion()
    allRegions.listing.item.name = "Countries"
    allRegions.listing.item.id = "top-level"
    itemStack.append(allRegions)
    session.currentRegion = countryList[indexPath.row]
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
