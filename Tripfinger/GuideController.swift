import RealmSwift

protocol GuideControllerDelegate: class {
  func categorySelected(category: Attraction.Category)
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
    
    self.automaticallyAdjustsScrollViewInsets = false
    
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.tableHeaderView = UIView.init(frame: CGRectZero)
    tableView.tableFooterView = UIView.init(frame: CGRectZero)
    
    
    UINib.registerNib(TableViewCellIdentifiers.guideItemCell, forTableView: tableView)
    UINib.registerNib(TableViewCellIdentifiers.categoryCell, forTableView: tableView)
    UINib.registerNib(TableViewCellIdentifiers.textChildCell, forTableView: tableView)
    UINib.registerNib(TableViewCellIdentifiers.loadingCell, forTableView: tableView)

    if let currentSection = currentSection {
      loadGuideTextWithId(currentSection.item.id)
    }
    else if let currentRegion = currentRegion {
      loadRegionWithID(currentRegion.listing.item.id)
    }
    else {
      loadRegionWithID("region-brussels")
    }
    
    let label = UILabel(frame: CGRectMake(10, 5, tableView.frame.size.width, 18))
    label.font = UIFont.boldSystemFontOfSize(16)
    label.text = "Brussels"
    let button = UIButton.init(type: UIButtonType.System)
    button.setTitle("Download", forState: UIControlState.Normal)
    button.titleLabel?.text = "Download"
    button.sizeToFit()
    button.addTarget(self, action: "openDownloadCity:", forControlEvents: UIControlEvents.TouchUpInside)
    
    let headerView = UIView()
    headerView.addSubview(label)
    headerView.addSubview(button)
    headerView.addConstraints("V:|-10-[title(22)]", forViews: ["title": label])
    headerView.addConstraints("V:|-10-[download(22)]", forViews: ["download": button])
    headerView.addConstraints("H:|-15-[title]-[download]-15-|", forViews: ["title": label, "download": button])
    var headerFrame = headerView.frame;
    headerFrame.size.height = 44;
    headerView.frame = headerFrame;
    tableView.tableHeaderView = headerView
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
      self.currentItem = region.listing.item
      self.session.currentRegion = region
      self.tableView.reloadData()
    }
  }
  
  func loadGuideTextWithId(guideTextId: String) {
    ContentService.getGuideTextWithId(guideTextId) {
      guideText in
      
      self.currentSection = guideText
      self.guideSections = guideText.item.guideSections
      self.currentItem = guideText.item
      self.title = guideText.item.name
      self.tableView.reloadData()
    }
  }
  
  override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
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
      return (currentSection != nil) ? 0 : 2
    case 3:
      return (currentSection != nil) ? 0 : Attraction.Category.allValues.count - 3
    default:
      return 0
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    if indexPath.section == 0 {
      if currentItem?.content != nil {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.guideItemCell, forIndexPath: indexPath) as! GuideItemCell
        cell.delegate = self
        cell.setContentFromGuideItem(currentItem!)
        if (guideItemExpanded) {
          cell.expand()
        }
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
      cell.textLabel?.text = Attraction.Category.allValues[index].entityName
      return cell
    }
  }
  
}

extension GuideController: GuideItemContainerDelegate {
  
  func readMoreClicked() {
    tableView.beginUpdates()
    tableView.endUpdates()
    
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
      
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      let vc = storyboard.instantiateViewControllerWithIdentifier("guideController") as! GuideController
      vc.currentRegion = currentRegion
      vc.currentSection = guideSections[indexPath.row]
      vc.guideItemExpanded = true
      self.navigationController?.pushViewController(vc, animated: true)
    }
    else if indexPath.section == 2 {
      delegate.categorySelected(Attraction.Category.allValues[indexPath.row + 1])
    }
    else if indexPath.section == 3 {
      if indexPath.row == 0 { // Transportation
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("guideController") as! GuideController
        
        vc.currentRegion = currentRegion
        vc.currentSection = guideSections[indexPath.row]
        vc.guideItemExpanded = true
        self.navigationController?.pushViewController(vc, animated: true)
      }
    }
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
}
