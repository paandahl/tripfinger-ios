import RealmSwift
import MBProgressHUD

class GuideItemController: TableController {
  
  weak var searchDelegate: SearchViewControllerDelegate!
  var contextSwitched = false
  var guideItemExpanded = false

  init(session: Session, searchDelegate: SearchViewControllerDelegate!) {
    self.searchDelegate = searchDelegate
    super.init(session: session)
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
    
    updateUI()
  }
  
  func navigationFailure() {
    self.navigationController?.popViewControllerAnimated(true)
    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
    let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    loadingNotification.mode = MBProgressHUDMode.CustomView
    loadingNotification.labelText = "Connection failed"
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue()) {
      MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
    }
  }

  
  func updateUI() {
    // if nil, we are in offline mode, changeRegion returned immediately, and viewdidload will trigger this method
    if let tableView = tableView {
      navigationItem.title = session.currentItem.name
      
      populateTableSections()
      tableView.reloadData {
        self.tableView.contentOffset = CGPointZero
      }
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    backButtonAction(self)
  }
  
  func backButtonAction(viewController: UIViewController) {
    if let navigationController = navigationController where
      navigationController.viewControllers.indexOf(viewController) == nil && !contextSwitched {
        guideItemExpanded = false
        let parentViewController = navigationController.viewControllers.last as? GuideItemController
        let failure = {
          fatalError("we're stranded")
        }
        session.moveBackInHierarchy(failure) {
          // sometimes we will get a ListingsController, but it's not possible to move to sections by search,
          // so it will note be necessary to update UI upon moving back
          if let parentViewController = parentViewController {
            if parentViewController.tableSections.count == 0 {
              parentViewController.updateUI()
            }
          }
        }
    }
  }
  
  func downloadClicked() {}
}

extension GuideItemController: GuideItemContainerDelegate {
  
  func readMoreClicked() {
    guideItemExpanded = true
    populateTableSections()
    tableView.reloadData()
  }
  
  func licenseClicked() {
    let licenseController: UIViewController
    if session.currentItem.textLicense == nil || session.currentItem.textLicense == "" && session.currentSection != nil {
      licenseController = LicenseController(textItem: session.currentRegion.item(), imageItem: session.currentItem)
    } else {
      licenseController = LicenseController(textItem: session.currentItem, imageItem: session.currentItem)
    }
    licenseController.edgesForExtendedLayout = .None // offset from navigation bar
    navigationController!.pushViewController(licenseController, animated: true)
  }
  
  func populateTableSections() {}
}

// MARK: - Navigation
extension GuideItemController {
  
  func navigateToSection(object: AnyObject) {
    let section = object as! GuideText
    
    let sectionController = SectionController(session: session, searchDelegate: searchDelegate)
    sectionController.edgesForExtendedLayout = .None // offset from navigation bar
    sectionController.navigationItem.title = title
    sectionController.guideItemExpanded = true
    navigationController!.pushViewController(sectionController, animated: true)
    
    session.changeSection(section, failure: navigationFailure) {
      sectionController.updateUI()
    }
  }

  func navigateToSearch() {
    let nav = UINavigationController()
    let regionId = session.currentRegion?.getId()
    let countryId = session.currentCountry?.getId()
    let searchController = SearchController(delegate: searchDelegate, regionId: regionId, countryId: countryId)
    nav.viewControllers = [searchController]
    presentViewController(nav, animated: true, completion: nil)
  }
  
  func navigateToMap() {
    let mapController = MapController(session: session)
    navigationController!.pushViewController(mapController, animated: true)
  }
}
