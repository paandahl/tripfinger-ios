import RealmSwift
import MBProgressHUD

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
    let licenseController = LicenseController(textLicense: guideItem.textLicense, imageItem: guideItem)
    navigationController!.pushViewController(licenseController, animated: true)
  }
  
  func populateTableSections() {}
  
  func jumpToRegion(path: String) {
    showLoadingHud()
    GuideItemController.navigateToRegionWithUrlPath(path, failure: showErrorHud, finishedHandler: hideHuds)
  }
  
  func jumpToListing(path: String) {
    showLoadingHud()
    GuideItemController.navigateToListingWithUrlPath(path, failure: showErrorHud, finishedHandler: hideHuds)
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
  
  class func navigateToRegionWithUrlPath(path: String, failure: () -> (), finishedHandler: () -> ()) {
    getRegionWithUrlPath(path, failure: failure) { region in
      getCountryForRegion(region, failure: failure) { country in
        let regionController = RegionController(region: region, countryMwmId: country.getDownloadId())
        TripfingerAppDelegate.navigationController.pushViewController(regionController, animated: true)
        finishedHandler()
      }
    }
  }
  
  class func navigateToListingWithUrlPath(path: String, failure: () -> (), finishedHandler: () -> ()) {
    let listingPartStart = path.rangeOfString("/l/")
    let regionPath = path.substringToIndex(listingPartStart!.startIndex)
    let listingSlug = path.substringFromIndex(listingPartStart!.endIndex)
    getRegionWithUrlPath(regionPath, failure: failure) { region in
      getCountryForRegion(region, failure: failure) { country in
        ContentService.getListingWithSlug(listingSlug, failure: failure) { listing in
          let entity = TripfingerEntity(listing: listing)
          MapsAppDelegateWrapper.openPlacePage(entity, withCountryMwmId: country.getDownloadId())
          finishedHandler()
        }
      }
    }
  }
  
  class func getCountryForRegion(region: Region, failure: () -> (), handler: Region -> ()) {
    if region.getCategory() == Region.Category.COUNTRY {
      handler(region)
    } else {
      ContentService.getCountryWithName(region.listing.country!, failure: failure) { country in
        handler(country)
      }
    }
  }
  
  class func getRegionWithUrlPath(path: String, failure: () -> (), finishedHandler: Region -> ()) {
    let urlParts = path.characters.split{$0 == "/"}.map(String.init)
    var regionNames = [String]()
    for urlPart in urlParts {
      regionNames.append(urlPart.stringByReplacingOccurrencesOfString("_", withString: " "))
    }
    if regionNames.count == 1 {
      let countryName = regionNames[0]
      ContentService.getCountryWithName(countryName, failure: failure, handler: finishedHandler)
    } else if regionNames.count == 2 {
      let countryName = regionNames[0]
      let subRegionName = regionNames[1]
      ContentService.getSubRegionWithName(subRegionName, countryName: countryName, failure: failure, handler: finishedHandler)
    } else if regionNames.count == 3 {
      let countryName = regionNames[0]
      let cityName = regionNames[2]
      ContentService.getCityWithName(cityName, countryName: countryName, failure: failure, handler: finishedHandler)
    } else {
      fatalError("Path \(path) resulted in too many parts: \(regionNames.count)")
    }
  }

}
