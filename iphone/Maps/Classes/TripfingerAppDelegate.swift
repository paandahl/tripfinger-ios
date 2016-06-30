import UIKit
import Alamofire
import CoreLocation
import Firebase
import FirebaseInstanceID
import FirebaseMessaging

class MyNavigationController: UINavigationController {  
  override func supportedInterfaceOrientations() -> UInt {
    let className = String(topViewController!.dynamicType)
    if className == "MapViewController" {
      return UInt(UIInterfaceOrientationMask.All.rawValue)
    } else {
      return UInt(UIInterfaceOrientationMask.Portrait.rawValue)
    }
  }
  
  func alert(message: String) {
    let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .Alert)
    let defaultAction = UIAlertAction(title: "OK", style: .Default) { alertAction in
      self.dismissViewControllerAnimated(true, completion: nil)
    }
    alertController.addAction(defaultAction)
    self.presentViewController(alertController, animated: true, completion: nil)
  }
}

@objc public class TripfingerAppDelegate: NSObject {
  
  static let sharedInstance = TripfingerAppDelegate()
  static var serverUrl = "https://1-3-dot-tripfinger-server.appspot.com"
  static var mode = AppMode.RELEASE
  static var coordinateSet = Set<Int64>()
  static let navigationController = MyNavigationController()
  var openUrl = ""

  class func applicationLaunched(application: UIApplication, delegate: UIApplicationDelegate, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> UIWindow {
    
    FIRApp.configure()

    TripfingerAppDelegate.styleNavigationBar(TripfingerAppDelegate.navigationController.navigationBar)
    print("myuuid: \(UniqueIdentifierService.uniqueIdentifier())")
    FIRAnalytics.setUserPropertyString(UniqueIdentifierService.uniqueIdentifier(), forName: "device_id")

    let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
    application.registerUserNotificationSettings(settings)
    
    FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    NSNotificationCenter.defaultCenter().addObserver(sharedInstance, selector: #selector(self.tokenRefreshNotification),
                                                     name: kFIRInstanceIDTokenRefreshNotification, object: nil)
    
    let isRunningTestFlightBeta = NSBundle.mainBundle().appStoreReceiptURL?.lastPathComponent=="sandboxReceipt"
    if NSProcessInfo.processInfo().arguments.contains("TEST") {
      print("Switching to test mode")
      TripfingerAppDelegate.mode = .TEST
    } else if !NSProcessInfo.processInfo().arguments.contains("RELEASE") && isRunningTestFlightBeta {
      let testMode = NSUserDefaults.standardUserDefaults().boolForKey("enableTestMode")
      if testMode {
        print("Switching to draft mode")
        TripfingerAppDelegate.mode = .DRAFT
      } else {
        TripfingerAppDelegate.mode = .BETA
      }
    }
    print("appMode: \(TripfingerAppDelegate.mode)")

    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    configuration.timeoutIntervalForRequest = 300 // seconds
    configuration.timeoutIntervalForResource = 60 * 60 * 48
    NetworkUtil.alamoFireManager = Alamofire.Manager(configuration: configuration)

    let window = UIWindow(frame: UIScreen.mainScreen().bounds)
    window.backgroundColor = UIColor.whiteColor()
    window.makeKeyAndVisible()
    TripfingerAppDelegate.navigationController.automaticallyAdjustsScrollViewInsets = false
    let regionController = CountryListController()
    TripfingerAppDelegate.navigationController.viewControllers = [regionController]
    window.rootViewController = TripfingerAppDelegate.navigationController

    if NSProcessInfo.processInfo().arguments.contains("OFFLINEMAP") {
      let failure = {
        assertionFailure("Connection failed")
      }
      ContentService.getCountryWithName("Brunei", failure: failure) { brunei in
        PurchasesService.makeCountryFirst(brunei, connectionError: failure) {
          DownloadService.downloadCountry("Brunei", progressHandler: { progress in }, failure: failure) {
            regionController.tableView.accessibilityValue = "bruneiReady"
          }
        }
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
  
  class func applicationDidBecomeActive(application: UIApplication) {
    FBSDKAppEvents.activateApp()
    connectToFcm()
  }
  
  class func application(application: UIApplication, openURL url: NSURL, sourceApplication: NSString, annotation: AnyObject) -> Bool {
    return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication as String, annotation: annotation)
  }
  
  class func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
                   fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    
    // Print message ID.
    print("received notification: ")
    print(userInfo)
    if let aps = userInfo["aps"] as? [String: String] {
      if let message = aps["alert"] {
        let openUrl = userInfo["openUrl"]
        let fromBackground = application.applicationState == .Inactive || application.applicationState == .Background
        
        if let openUrl = openUrl as? String {
          if fromBackground {
            UIApplication.sharedApplication().openURL(NSURL(string: openUrl)!)
          } else {
            sharedInstance.openUrl = openUrl
            let alert = UIAlertView(title: "", message: message, delegate: sharedInstance, cancelButtonTitle: "No thanks", otherButtonTitles: "Read more")
            alert.show()
          }
        }
      }
    }
    
    completionHandler(UIBackgroundFetchResult.NoData)
  }
  
  class func applicationDidEnterBackground(application: UIApplication) {
    FIRMessaging.messaging().disconnect()
    print("Disconnected from FCM.")
  }
  
  class func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
    if notificationSettings.types != .None {
      application.registerForRemoteNotifications()
    }
  }
  
  class func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
    var tokenString = ""
    
    for i in 0..<deviceToken.length {
      tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
    }
    
    //Tricky line
    FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.Unknown)
    print("Device Token:", tokenString)
  }
  
  func tokenRefreshNotification(notification: NSNotification) {
    print("tokenRefreshNotification")
    let refreshedToken = FIRInstanceID.instanceID().token()
    print("InstanceID token: \(refreshedToken)")
    TripfingerAppDelegate.connectToFcm()
  }
  
  class func connectToFcm() {
    FIRMessaging.messaging().connectWithCompletion { error in
      if error != nil {
        print("Unable to connect with FCM. \(error)")
      } else {
        print("Connected to FCM.")
        let refreshedToken = FIRInstanceID.instanceID().token()
        print("refreshedToken: \(refreshedToken)")
      }
    }
  }
  
  class func styleNavigationBar(bar: UINavigationBar) {
    let colorImage = UIImage(withColor: UIColor.primary(), frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 64))
    bar.setBackgroundImage(colorImage, forBarMetrics: .Default)
    bar.translucent = true
    bar.tintColor = UIColor.white()
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
    return TripfingerEntity(listing: listing)
  }

  public class func getOnlineListingById(listingId: String) -> TripfingerEntity {
    let semaphore = dispatch_semaphore_create(0)
    var retListing: Listing! = nil
    ContentService.getListingWithId(listingId, failure: connectionError, withNotes: false) { listing in
      retListing = listing
      dispatch_semaphore_signal(semaphore)
    }
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    return TripfingerEntity(listing: retListing)
  }
  
  public class func isListingOffline(listingId: String) -> Bool {
    return DatabaseService.getListingWithId(listingId) != nil
  }

  
  public class func getListingByCoordinate(coord: CLLocationCoordinate2D) -> TripfingerEntity {
    let listing = DatabaseService.getListingByCoordinate(coord)
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
    
  public class func displayPlacePage(views: [UIView], entity: TripfingerEntity, countryMwmId: String) {
    let detailController = DetailController(entity: entity, countryDownloadId: countryMwmId, placePageViews: views)
    if viewControllers.count > 0 {
      let newViewControllers = TripfingerAppDelegate.viewControllers + [detailController]
      TripfingerAppDelegate.navigationController.setViewControllers(newViewControllers, animated: true)
      TripfingerAppDelegate.viewControllers = [UIViewController]()
    } else {
      TripfingerAppDelegate.navigationController.pushViewController(detailController, animated: true)
    }
  }

  class func bookmarkAdded(listingId: String) {
    let listing = DatabaseService.getListingWithId(listingId)!
    DatabaseService.saveLike(GuideListingNotes.LikedState.LIKED, listing: listing, addNativeMarks: false)
  }
  
  class func bookmarkRemoved(listingId: String) {
    let listing = DatabaseService.getListingWithId(listingId)!
    DatabaseService.saveLike(GuideListingNotes.LikedState.SWIPED_LEFT, listing: listing, addNativeMarks: false)
  }

  class func moveToRegion(region: Region, stopSpinner: () -> (), handler: (String, UINavigationController, [UIViewController]) -> ()) {
    if region.getCategory() == Region.Category.COUNTRY {
      moveToRegion(region, countryMwmId: region.getDownloadId(), stopSpinner: stopSpinner, handler: handler)
    } else {
      ContentService.getCountryWithName(region.listing.country!, failure: connectionError) { country in
        moveToRegion(region, countryMwmId: country.getDownloadId(), stopSpinner: stopSpinner, handler: handler)
      }
    }
  }

  class func moveToRegion(region: Region, countryMwmId: String, stopSpinner: () -> (), handler: (String, UINavigationController, [UIViewController]) -> ()) {
    stopSpinner()
    
    let nav = TripfingerAppDelegate.navigationController
    for viewController in nav.viewControllers {
      if let regionController = viewController as? GuideItemController {
        regionController.contextSwitched = true
      }
    }
    
    nav.popToRootViewControllerAnimated(false)
    let regionListing = region.listing
    var viewControllers = [nav.viewControllers.first!]
    if region.item().category > Region.Category.COUNTRY.rawValue {
      let regionController = RegionController(region: Region.constructRegion(regionListing.country), countryMwmId: countryMwmId)
      viewControllers.append(regionController)
    }
    if region.item().category > Region.Category.SUB_REGION.rawValue {
      if region.listing.subRegion != nil {
        let regionController = RegionController(region: Region.constructRegion(regionListing.subRegion), countryMwmId: countryMwmId)
        viewControllers.append(regionController)
      }
    }
    if region.item().category > Region.Category.CITY.rawValue {
      let regionController = RegionController(region: Region.constructRegion(regionListing.city), countryMwmId: countryMwmId)
      viewControllers.append(regionController)
    }
    let regionController = RegionController(region: region, countryMwmId: countryMwmId)
    viewControllers.append(regionController)
    
    handler(countryMwmId, nav, viewControllers)
  }

  class func selectedSearchResult(searchResult: TripfingerEntity, failure: () -> (), stopSpinner: () -> ()) {
    TripfingerAppDelegate.navigationController.navigationBarHidden = false
    if searchResult.isListing() {
      jumpToListing(searchResult.tripfingerId, failure: failure, finishedHandler: stopSpinner)
    } else {
      jumpToRegion(searchResult.tripfingerId, failure: failure, finishedHandler: stopSpinner)
    }
  }
      
  class func jumpToRegion(regionId: String, failure: () -> (), finishedHandler: () -> ()) {
    ContentService.getRegionWithId(regionId, failure: failure) { region in
      TripfingerAppDelegate.moveToRegion(region, stopSpinner: finishedHandler) { country, nav, viewControllers in
        nav.setViewControllers(viewControllers, animated: true)
      }
      FIRAnalytics.logEventWithName(kFIREventSelectContent, parameters: [
        kFIRParameterContentType: "region",
        kFIRParameterItemID: region.getName()
        ])
    }
  }
  
  class func jumpToListing(listingId: String, failure: () -> (), finishedHandler: () -> ()) {
    ContentService.getListingWithId(listingId, failure: failure) { listing in
      ContentService.getRegionWithId(listing.item().parent, failure: failure) { region in
        TripfingerAppDelegate.moveToRegion(region, stopSpinner: finishedHandler) { countryMwmId, nav, viewControllers in
          let entity = TripfingerEntity(listing: listing)
          TripfingerAppDelegate.viewControllers = viewControllers
          MapsAppDelegateWrapper.openPlacePage(entity, withCountryMwmId: countryMwmId)
        }
      }
      FIRAnalytics.logEventWithName(kFIREventSelectContent, parameters: [
        kFIRParameterContentType: "listing",
        kFIRParameterItemID: listing.item().name
        ])
    }
  }
  
  class func isCountryDownloaded(countryName: String) -> Bool {
    return DownloadService.isCountryDownloaded(countryName)
  }
  
  // TODO: Add downloading-status
  class func downloadStatus(mwmCountryId: String) -> Int {
    
    var foundCountry = false
    let countryListController = TripfingerAppDelegate.navigationController.viewControllers[0] as! CountryListController
    for (_, countryList) in countryListController.countryLists {
      for country in countryList {
        if country.getDownloadId() == mwmCountryId {
          foundCountry = true
        }
      }
    }
    if !foundCountry {
      return 0
    }
    
    if DownloadService.isCountryDownloading(mwmCountryId) {
      return 1
    } else if DownloadService.isCountryDownloaded(mwmCountryId) {
      return 5
    } else { // NotDownloaded
      return 6
    }
  }
  
  class func countrySize(mwmCountryId: String) -> Int64 {
    let countryListController = TripfingerAppDelegate.navigationController.viewControllers[0] as! CountryListController
    for (_, countryList) in countryListController.countryLists {
      for country in countryList {
        if country.getDownloadId() == mwmCountryId {
          return country.getSizeInBytes()
        }
      }
    }
    LogUtils.assertionFailAndRemoteLog("Did not find size for country: \(mwmCountryId)")
    return 0
  }

  class func updateCountry(mwmCountryId: String, downloadStarted: () -> ()) {
    ContentService.getCountryWithName(mwmCountryId, failure: connectionError) { region in
      PurchasesService.proceedWithDownload(region, connectionError: connectionError)
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
  
  private class func connectionError() {
    TripfingerAppDelegate.navigationController.viewControllers.last!.showErrorHud()
  }
  
  class func purchaseCountry(mwmCountryId: String, downloadStarted: () -> ()) {
    TripfingerAppDelegate.navigationController.viewControllers.last!.showLoadingHud()
    ContentService.getCountryWithName(mwmCountryId, failure: connectionError) { region in
      PurchasesService.purchaseCountry(region, connectionError: connectionError) {
        dispatch_async(dispatch_get_main_queue()) {
          TripfingerAppDelegate.navigationController.viewControllers.last!.hideHuds()
          downloadStarted()
        }
      }
    }
  }
  
  class func isReleaseMode() -> Bool {
    return mode == .RELEASE
  }
  
  class func getDraftMode() -> Bool {
    return mode == .DRAFT
  }
  
  class func setDraftMode(draftMode: Bool) {
    if draftMode {
      NSUserDefaults.standardUserDefaults().setBool(true, forKey: "enableTestMode")
      mode = .DRAFT
    } else {
      NSUserDefaults.standardUserDefaults().setBool(false, forKey: "enableTestMode")
      mode = .BETA
    }
  }
  
  enum AppMode {
    case TEST
    case DRAFT
    case BETA
    case RELEASE
  }
}

extension TripfingerAppDelegate: UIAlertViewDelegate {
  
  public func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
    if buttonIndex == 1 {
      UIApplication.sharedApplication().openURL(NSURL(string: openUrl)!)
   }
  }
}