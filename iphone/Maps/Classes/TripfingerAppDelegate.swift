import UIKit
import Alamofire
import CoreLocation

class MyNavigationController: UINavigationController {
  
  override func supportedInterfaceOrientations() -> UInt {
    let className = String(topViewController!.dynamicType)
    if className == "MapViewController" {
      return UInt(UIInterfaceOrientationMask.All.rawValue)
    } else {
      return UInt(UIInterfaceOrientationMask.Portrait.rawValue)
    }
  }
}

@objc public class TripfingerAppDelegate: NSObject {
  
  static var serverUrl = "https://1-3-dot-tripfinger-server.appspot.com"
  static var mode = AppMode.BETA
  static var session: Session!
  static var coordinateSet = Set<Int64>()
  static let navigationController = MyNavigationController()

  public func applicationLaunched(application: UIApplication, delegate: UIApplicationDelegate, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> UIWindow {

    TripfingerAppDelegate.styleNavigationBar(TripfingerAppDelegate.navigationController.navigationBar)

//    let colorImage = UIImage(withColor: UIColor.primary(), frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 64))
//    TripfingerAppDelegate.navigationController.navigationBar.setBackgroundImage(colorImage, forBarMetrics: .Default)
//    TripfingerAppDelegate.navigationController.navigationBar.translucent = true
    print("myuuid: \(UniqueIdentifierService.uniqueIdentifier())")
    
    if NSProcessInfo.processInfo().arguments.contains("TEST") {
      print("Switching to test mode")
      TripfingerAppDelegate.mode = AppMode.TEST
    }

    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    configuration.timeoutIntervalForRequest = 300 // seconds
    configuration.timeoutIntervalForResource = 60 * 60 * 48
    NetworkUtil.alamoFireManager = Alamofire.Manager(configuration: configuration)

    TripfingerAppDelegate.session = Session()

    print("didFinishLaunchingWithOptions!!")
    let window = UIWindow(frame: UIScreen.mainScreen().bounds)
    window.backgroundColor = UIColor.whiteColor()
    window.makeKeyAndVisible()
    TripfingerAppDelegate.navigationController.automaticallyAdjustsScrollViewInsets = false
    let regionController = RegionController(session: TripfingerAppDelegate.session)
    TripfingerAppDelegate.navigationController.viewControllers = [regionController]
    window.rootViewController = TripfingerAppDelegate.navigationController

    if NSProcessInfo.processInfo().arguments.contains("OFFLINEMAP") {
      print("Installing test-map before offline-mode")
      let failure = {
        fatalError("Connection failed")
      }
      DownloadService.downloadCountry("Brunei", progressHandler: { progress in }, failure: failure) {
        print("Brunei download finished")
        regionController.loadCountryLists() // remove online countries from list
        regionController.tableView.accessibilityValue = "bruneiReady"
      }
      NetworkUtil.simulateOffline = true
    } else if NSProcessInfo.processInfo().arguments.contains("OFFLINE") {
      print("Simulating offline mode")
      NetworkUtil.simulateOffline = true
    } else {
      DownloadService.resumeDownloads()      
    }
    
    TripfingerAppDelegate.coordinateSet = DatabaseService.getCoordinateSet()
    print("fetched coordinateSet: ")
    print(TripfingerAppDelegate.coordinateSet)

    return window
  }
  
  class func styleNavigationBar(bar: UINavigationBar) {
    let colorImage = UIImage(withColor: UIColor.primary(), frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 64))
    bar.setBackgroundImage(colorImage, forBarMetrics: .Default)
    bar.translucent = true
    bar.tintColor = UIColor.white()
  }
  
  public class func applicationDidBecomeActive(application: UIApplication) {
  }
  
  public class func getPoisForArea(topLeft: CLLocationCoordinate2D, bottomRight: CLLocationCoordinate2D, zoomLevel: Int) -> [TripfingerEntity] {
    
    if zoomLevel < 10 {
      return [TripfingerEntity]()
    }

    let topRight = CLLocationCoordinate2DMake(topLeft.latitude, bottomRight.longitude)
    let bottomLeft = CLLocationCoordinate2DMake(bottomRight.latitude, topLeft.longitude)
    let listings = DatabaseService.getPois(bottomLeft, topRight: topRight, zoomLevel: 15)

    var entities = [TripfingerEntity]()
    for listing in listings {
      let entity = TripfingerEntity(listing: listing)
      entities.append(entity)
    }

    print("Fetched \(entities.count) entities. botLeft: \(bottomLeft), topRight: \(topRight)")
    return entities;
  }
  
  public class func getPoisForArea(topLeft: CLLocationCoordinate2D, bottomRight: CLLocationCoordinate2D, category: Int) -> [TripfingerEntity] {
    
    let topRight = CLLocationCoordinate2DMake(topLeft.latitude, bottomRight.longitude)
    let bottomLeft = CLLocationCoordinate2DMake(bottomRight.latitude, topLeft.longitude)
    let listings = DatabaseService.getPois(bottomLeft, topRight: topRight, category: category)
    
    var entities = [TripfingerEntity]()
    for listing in listings {
      let entity = TripfingerEntity(listing: listing)
      entities.append(entity)
    }
    
    print("Cat-fetched \(entities.count) entities. botLeft: \(bottomLeft), topRight: \(topRight)")    
    return entities;
  }
  
  public class func poiSearch(query: String, includeRegions: Bool) -> [TripfingerEntity] {
    let semaphore = dispatch_semaphore_create(0)
    let searchService = SearchService()
    var entities = [TripfingerEntity]()
    searchService.search(query) { results in
      for poi in results {
        if includeRegions || Listing.Category(rawValue: poi.category) != nil {
          let entity = TripfingerEntity(poi: poi)
          entities.append(entity)
        }
      }
      dispatch_semaphore_signal(semaphore)
    }
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    
    return entities
  }

  public class func getOfflineListingById(listingId: String) -> TripfingerEntity {
    let listing = DatabaseService.getListingWithId(listingId)!
    session.currentListing = listing
    return TripfingerEntity(listing: listing)
  }

  public class func getOnlineListingById(listingId: String) -> TripfingerEntity {
    let semaphore = dispatch_semaphore_create(0)
    var retListing: Listing! = nil
    ContentService.getListingWithId(listingId, failure: {fatalError("connection issue while fetching listing")}, withNotes: false) { listing in
      retListing = listing
      dispatch_semaphore_signal(semaphore)
    }
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    session.currentListing = retListing
    return TripfingerEntity(listing: retListing)
  }
  
  public class func isListingOffline(listingId: String) -> Bool {
    return DatabaseService.getListingWithId(listingId) != nil
  }

  
  public class func getListingByCoordinate(coord: CLLocationCoordinate2D) -> TripfingerEntity {
    let listing = DatabaseService.getListingByCoordinate(coord)
    session.currentListing = listing
    let entity = TripfingerEntity(listing: listing!)
    return entity
  }

  public class func coordinateToInt(coord: CLLocationCoordinate2D) -> Int64 {
    let latInt = Int64(abs(coord.latitude * 1000000) + 0.5)
    let lonInt = Int64(abs(coord.longitude * 1000000) + 0.5)
    let sign: Int64
    if coord.latitude >= 0 && coord.longitude >= 0 {
      sign = 1
    } else if coord.latitude >= 0 {
      sign = 2
    } else if coord.longitude >= 0 {
      sign = 3
    } else {
      sign = 4
    }
    return (sign * 100000000000000000) + (latInt * 100000000) + lonInt
  }
  
  public class func coordinateExists(coord: CLLocationCoordinate2D) -> Bool {
    let intCoord = coordinateToInt(coord)
    let exists = TripfingerAppDelegate.coordinateSet.contains(intCoord)
    return exists
  }
  
  public class func nameToCategoryId(name: String) -> Int {
    let trimmedString = name.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    if let cat = Listing.Category.entityMap[trimmedString] {
      print("returning category with entName: \(cat.entityName)")
      return cat.rawValue
    } else {
      return 0
    }
  }
  
  static var viewControllers = [UIViewController]()
    
  public class func displayPlacePage(views: [UIView]) {
    let detailController = DetailController(session: session, placePageViews: views)
    if viewControllers.count > 0 {
      let newViewControllers = TripfingerAppDelegate.viewControllers + [detailController]
      TripfingerAppDelegate.navigationController.setViewControllers(newViewControllers, animated: true)
      TripfingerAppDelegate.viewControllers = [UIViewController]()
    } else {
      TripfingerAppDelegate.navigationController.pushViewController(detailController, animated: true)
    }
  }
  
  class func navigateToLicense() { // for listings from map
    let licenseController: UIViewController
    licenseController = LicenseController(textItem: session.currentListing.item(), imageItem: session.currentListing.item())
    licenseController.edgesForExtendedLayout = .None // offset from navigation bar
    TripfingerAppDelegate.navigationController.pushViewController(licenseController, animated: true)
  }

  class func bookmarkAdded(listingId: String) {
    let listing = DatabaseService.getListingWithId(listingId)!
    DatabaseService.saveLike(GuideListingNotes.LikedState.LIKED, listing: listing, addNativeMarks: false)
  }
  
  class func bookmarkRemoved(listingId: String) {
    let listing = DatabaseService.getListingWithId(listingId)!
    DatabaseService.saveLike(GuideListingNotes.LikedState.SWIPED_LEFT, listing: listing, addNativeMarks: false)
  }
  
  class func moveToRegion(stopSpinner: () -> (), handler: (UINavigationController, [UIViewController]) -> ()) {
    let session = TripfingerAppDelegate.session
    stopSpinner()
    
    let nav = TripfingerAppDelegate.navigationController
    for viewController in nav.viewControllers {
      if let regionController = viewController as? GuideItemController {
        regionController.contextSwitched = true
      }
    }
    
    nav.popToRootViewControllerAnimated(false)
    let currentListing = session.currentRegion.listing
    var viewControllers = [nav.viewControllers.first!]
    if session.currentRegion.item().category > Region.Category.COUNTRY.rawValue {
      viewControllers.append(RegionController.constructRegionController(session, title: currentListing.country))
    }
    if session.currentRegion.item().category > Region.Category.SUB_REGION.rawValue {
      if session.currentRegion.listing.subRegion != nil {
        viewControllers.append(RegionController.constructRegionController(session, title: currentListing.subRegion))
      }
    }
    if TripfingerAppDelegate.session.currentRegion.item().category > Region.Category.CITY.rawValue {
      viewControllers.append(RegionController.constructRegionController(session, title: currentListing.city))
    }
    viewControllers.append(RegionController.constructRegionController(session))
    
    handler(nav, viewControllers)
  }

  class func selectedSearchResult(searchResult: TripfingerEntity, failure: () -> (), stopSpinner: () -> ()) {
    if searchResult.isListing() {
      jumpToListing(searchResult.tripfingerId, failure: failure, stopSpinner: stopSpinner)
    } else {
      jumpToRegion(searchResult.tripfingerId, failure: failure, stopSpinner: stopSpinner)
    }
  }
  
  class func jumpToRegionWithUrlPath(path: String, failure: () -> (), stopSpinner: () -> ()) {

    let handler = { region in
      session.changeRegion(region, failure: failure) { _ in
        TripfingerAppDelegate.moveToRegion(stopSpinner) { nav, viewControllers in
          nav.setViewControllers(viewControllers, animated: true)
        }
      }
    }
    
    let failure = {
      fatalError("errror 200nx")
    }
    
    let urlParts = path.characters.split{$0 == "/"}.map(String.init)
    var regionNames = [String]()
    for urlPart in urlParts {
      regionNames.append(urlPart.stringByReplacingOccurrencesOfString("_", withString: " "))
    }
    if regionNames.count == 1 {
      let countryName = regionNames[0]
      print("Jumping to country: \(countryName)")
      ContentService.getCountryWithName(countryName, failure: failure, handler: handler)
    } else if regionNames.count == 2 {
      let countryName = regionNames[0]
      let subRegionName = regionNames[1]
      print("Jumping to region: \(subRegionName)")
      ContentService.getSubRegionWithName(subRegionName, countryName: countryName, failure: failure, handler: handler)
    } else if regionNames.count == 3 {
      let countryName = regionNames[0]
      let cityName = regionNames[2]
      print("Jumping to city: \(cityName)")
      ContentService.getCityWithName(cityName, countryName: countryName, failure: failure, handler: handler)
    } else {
      fatalError("Path \(path) resulted in too many parts: \(regionNames.count)")
    }
  }

  
  class func jumpToRegion(regionId: String, failure: () -> (), stopSpinner: () -> ()) {
    session.loadRegionFromId(regionId, failure: failure) {
      TripfingerAppDelegate.moveToRegion(stopSpinner) { nav, viewControllers in
        nav.setViewControllers(viewControllers, animated: true)
      }
    }
  }
  
  class func jumpToListing(listingId: String, failure: () -> (), stopSpinner: () -> ()) {
    ContentService.getListingWithId(listingId, failure: failure) { listing in
      TripfingerAppDelegate.session.loadRegionFromId(listing.item().parent, failure: failure ) {
        TripfingerAppDelegate.moveToRegion(stopSpinner) { nav, viewControllers in
          session.currentListing = listing
          let entity = TripfingerEntity(listing: listing)
          TripfingerAppDelegate.viewControllers = viewControllers
          MapsAppDelegateWrapper.openPlacePage(entity)
        }
      }
    }
  }
  
  class func isCountryDownloaded(countryName: String) -> Bool {
    return DownloadService.isCountryDownloaded(countryName)
  }
  
  // TODO: Add downloading-status
  class func downloadStatus(mwmCountryId: String) -> Int {
    if DownloadService.isCountryDownloading(mwmCountryId) {
      return 1;
    } else if DownloadService.isCountryDownloaded(mwmCountryId) {
      return 5;
    } else { // NotDownloaded
      return 6;
    }
  }

  class func updateCountry(mwmCountryId: String, downloadStarted: () -> ()) {
    ContentService.getCountryWithName(mwmCountryId, failure: {fatalError("fail86")}) { region in
      PurchasesService.proceedWithDownload(region)
      downloadStarted()
    }
  }
  
  class func cancelDownload(mwmRegionId: String) {
    DownloadService.cancelDownload(mwmRegionId)
  }

  class func deleteCountry(mwmCountryId: String) {
    let region = DatabaseService.getCountryWithMwmId(mwmCountryId)
    DownloadService.deleteCountry(region.getName())
  }
  
  class func purchaseCountry(mwmCountryId: String, downloadStarted: () -> ()) {
    ContentService.getCountryWithName(mwmCountryId, failure: {fatalError("fail86")}) { region in
      PurchasesService.purchaseCountry(region)
      downloadStarted()
    }
  }
  
  enum AppMode {
    case TEST
    case BETA
    case RELEASE
  }
}