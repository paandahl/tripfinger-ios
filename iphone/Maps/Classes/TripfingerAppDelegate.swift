import UIKit
import Alamofire
import CoreLocation

@objc public class TripfingerAppDelegate: NSObject {
  
  static var serverUrl = "https://1-3-dot-tripfinger-server.appspot.com"
  static var mode = AppMode.BETA
  static var session: Session!

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
    let nav = UINavigationController()
    nav.automaticallyAdjustsScrollViewInsets = false
    let regionController = RegionController(session: TripfingerAppDelegate.session)
    regionController.edgesForExtendedLayout = .None // offset from navigation bar
    nav.viewControllers = [regionController]
    window.rootViewController = nav

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

    return window
  }
  
  static var identifier: Int32 = 789000
  static var idMap: [Int32: String] = [Int32: String]()

  public class func getPoisForArea(topLeft: CLLocationCoordinate2D, bottomRight: CLLocationCoordinate2D) -> [TripfingerAnnotation] {

//    let bottomLeft = CLLocationCoordinate2DMake(topLeft.latitude, bottomRight.longitude)
//    let topRight = CLLocationCoordinate2DMake(bottomRight.latitude, topLeft.longitude)
    let bottomLeft = CLLocationCoordinate2DMake(-180, -90)
    let topRight = CLLocationCoordinate2DMake(180, 90)
    let pois = DatabaseService.getPois(bottomLeft, topRight: topRight, zoomLevel: 15, category: session.currentCategory)
      ////          searchResults in
      ////
      ////          self.pois = searchResults
      ////          self.addAnnotations()
      ////        }

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

//    let annotation = TripfingerAnnotation()
//    annotation.name = "Cunt Airport";
//    annotation.lat = 43.257673;
//    annotation.lon = 76.954907;
//    annotation.identifier = 789032;
//    return [annotation];
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
  
  public class func coordinateToInt(coord: CLLocationCoordinate2D) -> Int {
    let latInt = Int(coord.latitude * 6)
    let lonInt = Int(coord.longitude * 6)
    let sign: Int
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


  enum AppMode {
    case TEST
    case BETA
    case RELEASE
  }
}