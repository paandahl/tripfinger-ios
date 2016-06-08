import RealmSwift
import MBProgressHUD

class GuideItemController: TableController {
  
  var newContentDownloaded = false
  var contextSwitched = false
  var guideItemExpanded = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print("view.translatesAutoresizingMaskIntoConstraints: \(view.translatesAutoresizingMaskIntoConstraints)")
    
    let mapButton = UIBarButtonItem(image: UIImage(named: "maps_icon"), style: .Plain, target: self, action: #selector(GuideItemController.navigateToMap))
    mapButton.accessibilityLabel = "Map"
    let searchButton = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: #selector(GuideItemController.navigateToSearch))
    navigationItem.rightBarButtonItems = [searchButton, mapButton]
    
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 44.0;
    tableView.tableHeaderView = UIView.init(frame: CGRectMake(0.0, 0.0, tableView.bounds.size.width, 0.01))
    tableView.tableFooterView = UIView.init(frame: CGRectZero)
    
    updateUI()
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(newRegionDownloaded),
                                                     name: DownloadService.TFDownloadNotification,
                                                     object: nil)
    
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    gestureRecognizer.cancelsTouchesInView = false
    view.addGestureRecognizer(gestureRecognizer)
  }

  func handleTap(recognizer: UIGestureRecognizer) {
    print("tapped: \(recognizer.locationInView(view))")
  }

  override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask.Portrait
  }
  
  func newRegionDownloaded() {
    if self == TripfingerAppDelegate.navigationController.topViewController {
      updateUI()
    } else {
      newContentDownloaded = true      
    }
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
      tableView.reloadData {}
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    backButtonAction(self)
  }
  
//  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//    print("will display: \(cell.textLabel?.text)")
//  }
//  
//  func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//    print("ended displaying: \(cell.textLabel?.accessibilityLabel)")
//    cell.textLabel?.accessibilityLabel = nil
//    cell.textLabel?.accessibilityIdentifier = nil
//    cell.textLabel?.text = nil
//  }
  
  override func willMoveToParentViewController(parent: UIViewController?) {
    if parent != nil {
      return
    }
    print("navigating back")
    if !contextSwitched {
      print("back button action")
      guideItemExpanded = false
      let failure = {
        fatalError("we're stranded")
      }
      session.moveBackInHierarchy(failure) { loadedNew in
        // sometimes we will get a ListingsController, but it's not possible to move to sections by search,
        // so it will note be necessary to update UI upon moving back
        print("loadedNew: \(loadedNew)")
        if self.newContentDownloaded || loadedNew {
          self.newContentDownloaded = false
          dispatch_async(dispatch_get_main_queue()) {
            print("calling updateUI on parent")
            let newController = TripfingerAppDelegate.navigationController.viewControllers.last as! GuideItemController
            newController.updateUI()
          }
        }
      }
    }
  }
  
  func backButtonAction(viewController: UIViewController) {
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
  
  func jumpToRegion(path: String) {
    showLoadingHud()
    TripfingerAppDelegate.jumpToRegionWithUrlPath(path, failure: showErrorHud, finishedHandler: hideHuds)
  }
  
  func jumpToListing(path: String) {
    showLoadingHud()
    TripfingerAppDelegate.jumpToListingWithUrlPath(path, failure: showErrorHud, finishedHandler: hideHuds)
  }
}

// MARK: - Navigation
extension GuideItemController {
  
  func navigateToSection(object: AnyObject) {
    print("Navigation to section")
    let section = object as! GuideText
    
    let sectionController = SectionController(session: session)
    sectionController.navigationItem.title = title
    sectionController.guideItemExpanded = true
    navigationController!.pushViewController(sectionController, animated: true)
    
    session.changeSection(section, failure: navigationFailure) { _ in
      sectionController.updateUI()
    }
  }

  func navigateToSearch() {
    let vc = MapsAppDelegateWrapper.getMapViewController()
    navigationController!.pushViewController(vc, animated: true)
    MapsAppDelegateWrapper.openSearch()
  }
  
  func navigateToMap() {
    let vc = MapsAppDelegateWrapper.getMapViewController()
    navigationController!.pushViewController(vc, animated: true)
    
    if let region = self.session.currentRegion {
      FrameworkService.navigateToRegionOnMap(region)
    }
  }
}
