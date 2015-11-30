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
  
  var currentItem: GuideItem?
  var currentRegion: Region?
  var currentSection: GuideText?
  var guideSections = List<GuideText>()
  var currentCategoryDescriptions = List<GuideText>()
  var guideItemExpanded = false
  var guideITemCreatedAsExpanded = false
  var containerFrame: CGRect!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let belgium = Region.constructRegion()
    belgium.listing.item.id = "region-belgium"
    belgium.listing.item.name = "Belgium"
    itemStack.append(belgium)
    
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

    let downloadButton = UIButton(type: UIButtonType.System)
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
    if (stackItem.getId().hasPrefix("region-")) {
      print("Setting currentSection to nil")
      currentSection = nil
      session.currentSection = nil
    }
    else {
      currentSection = nil
      session.currentSection = stackItem as? GuideText
    }
    loadContent()
    delegate.navigateInternally()
  }
  
  func loadContent() {
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
      loadRegionWithID(session.currentItemId)
    }
    
    if let currentSection = currentSection {
      print(currentSection.item.category)
      let category = Attraction.Category(rawValue: currentSection.item.category)
      titleLabel.text = category?.entityName
    }
    print(itemStack.count)
    let stackElement = itemStack.last!
    print(stackElement.getName())
    backButton.setTitle("< \(stackElement.getName())", forState: UIControlState.Normal)
    backButton.sizeToFit()
    
  }
  
  func openDownloadCity(sender: UIButton) {
    let nav = UINavigationController()
    let vc = DownloadController()
    nav.viewControllers = [vc]
    presentViewController(nav, animated: true, completion: nil)
  }
  
  func loadRegionWithID(regionId: String) {
    
    ContentService.getRegionWithId(regionId) {
      region in
      
      self.currentRegion = region
      self.guideSections = region.listing.item.guideSections
      self.currentCategoryDescriptions = region.listing.item.categoryDescriptions
      print("CategoryDescriptions: \(self.currentCategoryDescriptions.count)")
      self.currentItem = region.listing.item
      self.titleLabel.text = self.currentItem!.name
      self.session.currentRegion = region
      self.tableView.reloadData()
    }
  }
  
  func loadGuideTextWithId(guideTextId: String) {
    ContentService.getGuideTextWithId(currentRegion!, guideTextId: guideTextId) {
      guideText in
      
      self.currentSection = guideText
      self.guideSections = guideText.item.guideSections
      self.currentItem = guideText.item
      self.title = guideText.item.name
      self.tableView.reloadData()
    }
  }

  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section == 1 && !guideItemExpanded {
      return 1
    }
    else {
      return super.tableView(tableView, heightForHeaderInSection: section)
    }
  }
  
  override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    if section == 0 && !guideItemExpanded {
      return 1
    }
    else {
      return super.tableView(tableView, heightForHeaderInSection: section)
    }
  }
}

// MARK: - Table data source
extension GuideController {
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 4;
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return 1
    case 1:
      return guideItemExpanded ? guideSections.count : 0;
    case 2:
      if currentSection != nil {
        if currentSection?.item.category == 0 {
          return 0
        }
        else {
          return 1
        }
      }
      else {
        return 2
      }
    case 3:
      return (currentSection != nil) ? 0 : Attraction.Category.allValues.count - 3
    default:
      return 0
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    if indexPath.section == 0 {
      if currentItem?.content != nil || currentItem?.id == "null" {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.guideItemCell, forIndexPath: indexPath) as! GuideItemCell
        cell.delegate = self
        cell.setContentFromGuideItem(currentItem!)
        if (guideItemExpanded) {
          cell.expand()
        }
        cell.setNeedsUpdateConstraints()
        return cell
      }
      else {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath)
        let indicator = cell.viewWithTag(1000) as! UIActivityIndicatorView
        indicator.startAnimating()
        return cell
      }
    }
    else if indexPath.section == 1 && guideItemExpanded {
      let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.categoryCell, forIndexPath: indexPath)
      cell.textLabel?.text = guideSections[indexPath.row].item.name
      return cell
    }
    else {
      let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.categoryCell, forIndexPath: indexPath)
      let index: Int
      if indexPath.section == 2 {
        index = indexPath.row + 1
      }
      else {
        index = indexPath.row + 3
      }
      if indexPath.section == 2 && currentSection != nil && currentSection?.item.category != 0 {
        cell.textLabel?.text = "Browse"
      }
      else {
        cell.textLabel?.text = Attraction.Category.allValues[index].entityName
      }
      return cell
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
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.section == 1 && guideItemExpanded {
      
      var current: GuideItemHolder = currentRegion!
      if let currentSection = currentSection {
        current = currentSection
      }
      session.currentSection = guideSections[indexPath.row]
      itemStack.append(current)
      loadContent()
      delegate.navigateInternally()
    }
    else if indexPath.section == 2 {
      if currentSection != nil {
        let category = Attraction.Category(rawValue: currentSection!.item.category)!
        delegate.categorySelected(category)
        
      }
      else {
        delegate.categorySelected(Attraction.Category.allValues[indexPath.row + 1])
      }
    }
    else if indexPath.section == 3 {
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
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
}
