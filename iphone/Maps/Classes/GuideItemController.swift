import RealmSwift
import MBProgressHUD
import Firebase

class GuideItemController: TableController {
  
  let guideItem: GuideItem
  var contextSwitched = false
  var guideItemExpanded = false
  
  init(guideItem: GuideItem) {
    self.guideItem = guideItem
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let mapButton = UIBarButtonItem(image: UIImage(named: "maps_icon"), style: .Plain, target: self, action: #selector(navigateToMap))
    mapButton.accessibilityLabel = "Map"
    let searchButton = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: #selector(navigateToSearch))
    navigationItem.rightBarButtonItems = [searchButton, mapButton]
    
    tableView.tableHeaderView = UIView.init(frame: CGRectMake(0.0, 0.0, tableView.bounds.size.width, 0.01))
    tableView.tableFooterView = UIView.init(frame: CGRectZero)
    
    updateUI()
  }

  override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask.Portrait
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
    populateTableSections()
    tableView.reloadData {}
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
    let licenseController = LicenseController(guideItem: guideItem)
    navigationController!.pushViewController(licenseController, animated: true)
  }
  
  func populateTableSections() {}
  
  func navigateToTripfingerUrl(url: TripfingerUrl) {
    showLoadingHud()
    TripfingerAppDelegate.navigationController.navigateToTripfingerUrl(url, failure: showErrorHud, finishedHandler: hideHuds)
  }
}

// MARK: - Navigation
extension GuideItemController {
  
  func navigateToSearch() {
    let vc = MapsAppDelegateWrapper.getMapViewController()
    navigationController!.pushViewController(vc, animated: true)
    MapsAppDelegateWrapper.openSearch()
  }
  
  func navigateToMap() {
    preconditionFailure("Navigate to map must be overridden.")
  }
}
