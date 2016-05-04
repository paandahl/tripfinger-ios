import UIKit
import Alamofire
import CoreLocation

@objc public class TripfingerAppDelegate: NSObject {
  
  static var serverUrl = "https://1-3-dot-tripfinger-server.appspot.com"
  static var mode = AppMode.BETA
  static var session: Session!
  static var coordinateSet = Set<Int64>()
  static let navigationController = UINavigationController()

  public func applicationLaunched(application: UIApplication, delegate: UIApplicationDelegate, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> UIWindow {
    
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
    regionController.edgesForExtendedLayout = .None // offset from navigation bar
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
    }
    
    TripfingerAppDelegate.coordinateSet = DatabaseService.getCoordinateSet()
    print("fetched coordinateSet: ")
    print(TripfingerAppDelegate.coordinateSet)

    return window
  }
  
  static var identifier: Int32 = 789000
  static var idMap: [Int32: String] = [Int32: String]()

  public class func getPoisForArea(topLeft: CLLocationCoordinate2D, bottomRight: CLLocationCoordinate2D, zoomLevel: Int) -> [TripfingerAnnotation] {
    
    if zoomLevel < 10 {
      return [TripfingerAnnotation]()
    }

    let topRight = CLLocationCoordinate2DMake(topLeft.latitude, bottomRight.longitude)
    let bottomLeft = CLLocationCoordinate2DMake(bottomRight.latitude, topLeft.longitude)
    let pois = DatabaseService.getPois(bottomLeft, topRight: topRight, zoomLevel: 15) //, category: session.currentCategory)

    var annotations = [TripfingerAnnotation]()

    for poi in pois {
      let annotation = TripfingerAnnotation()
      annotation.name = poi.name
      annotation.lat = poi.latitude
      annotation.lon = poi.longitude
      annotation.type = Int32(Listing.SubCategory(rawValue: poi.subCategory)!.osmType)
      let annotationId = identifier
      identifier += 1
      if identifier >= 790000 {
        identifier = 789000
      }
      idMap[annotationId] = poi.listingId!
      annotation.identifier = annotationId
      annotations.append(annotation)
    }

    print("Fetched \(annotations.count) annotations. botLeft: \(bottomLeft), topRight: \(topRight)")

    return annotations;
  }

  public class func getPoiById(id: Int32) -> TripfingerAnnotation {
    let listingId = idMap[id]!
    let listing = DatabaseService.getListingWithId(listingId)
    let annotation = TripfingerAnnotation()
    annotation.name = listing?.item().name
    annotation.lat = listing!.listing.latitude
    annotation.lon = listing!.listing.longitude
    annotation.type = Int32(Listing.SubCategory(rawValue: listing!.item().subCategory)!.osmType)
    return annotation
  }

  public class func getListingById(id: Int32) -> TripfingerEntity {
    let listingId = idMap[id]!
    let listing = DatabaseService.getListingWithId(listingId)!
    return TripfingerEntity(listing: listing)
  }

  public class func coordinateToInt(coord: CLLocationCoordinate2D) -> Int64 {
    let latInt = Int64((coord.latitude * 1000000) + 0.5)
    let lonInt = Int64((coord.longitude * 1000000) + 0.5)
    let sign: Int64
    if latInt >= 0 && lonInt >= 0 {
      sign = 1
    } else if latInt >= 0 {
      sign = 2
    } else if lonInt >= 0 {
      sign = 3
    } else {
      sign = 4
    }
    return (sign * 100000000000000000) + (abs(latInt) * 100000000) + abs(lonInt)
  }
  
  public class func coordinateExists(coord: CLLocationCoordinate2D) -> Bool {
    let intCoord = coordinateToInt(coord)
    let exists = TripfingerAppDelegate.coordinateSet.contains(intCoord)
    return exists
  }
  
  static var viewControllers = [UIViewController]()
    
  public class func displayPlacePage(views: [UIView]) {
    let searchDelegate = TripfingerAppDelegate.navigationController.viewControllers[0] as! RegionController
    let detailController = DetailController(session: session, searchDelegate: searchDelegate, placePageViews: views)
    if viewControllers.count > 0 {
      let newViewControllers = TripfingerAppDelegate.viewControllers + [detailController]
      TripfingerAppDelegate.navigationController.setViewControllers(newViewControllers, animated: true)
      TripfingerAppDelegate.viewControllers = [UIViewController]()
    } else {
      TripfingerAppDelegate.navigationController.pushViewController(detailController, animated: true)
    }
  }
  
  class func navigateToLicense() {
    let licenseController: UIViewController
    if session.currentItem.textLicense == nil || session.currentItem.textLicense == "" && session.currentSection != nil {
      licenseController = LicenseController(textItem: session.currentRegion.item(), imageItem: session.currentItem)
    } else {
      licenseController = LicenseController(textItem: session.currentItem, imageItem: session.currentItem)
    }
    licenseController.edgesForExtendedLayout = .None // offset from navigation bar
    TripfingerAppDelegate.navigationController.pushViewController(licenseController, animated: true)
  }

  
//  public class func getImageViewCell() -> UIView {
//    
//  }

  enum AppMode {
    case TEST
    case BETA
    case RELEASE
  }
}