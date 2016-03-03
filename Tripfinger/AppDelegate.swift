import UIKit
import SKMaps
import BrightFutures
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SKMapVersioningDelegate {
  
  static var serverUrl = "https://1-1-dot-tripfinger-server.appspot.com"
  static var metadataCallback: (() -> ())? // hack to know when maps are indexed in tests
  static var mode = AppMode.BETA
  var window: UIWindow!
  static var session: Session!
  
  func initUITestMaps() -> String {
    var mapsPath = NSURL.createDirectory(.LibraryDirectory, withPath: "Caches/testMaps")
    NSURL.deleteFolder(mapsPath)
    mapsPath = NSURL.createDirectory(.LibraryDirectory, withPath: "Caches/testMaps")
    print("initUItestMaps")
    return mapsPath.path!
  }
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    print("UIDevice id \(UIDevice.currentDevice().identifierForVendor)")

    if NSProcessInfo.processInfo().arguments.contains("TEST") {
      print("Switching to test mode")
      AppDelegate.mode = AppMode.TEST
    }
  
    let URLCache = NSURLCache(memoryCapacity: 20 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: nil)
    NSURLCache.setSharedURLCache(URLCache)
    let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    print("Path: \(path[0])")
    
    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    configuration.timeoutIntervalForRequest = 300 // seconds
    configuration.timeoutIntervalForResource = 300
    NetworkUtil.alamoFireManager = Alamofire.Manager(configuration: configuration)
    
    let apiKey = "0511a5e338b00db8b426fb8ec0a7fb2ebd6816bb9324425d4edd9b726e40a3d5"
    let initSettings: SKMapsInitSettings = SKMapsInitSettings()
    if AppDelegate.mode == AppMode.TEST {
      print("cachesPath: \(initSettings.cachesPath)")
      initSettings.cachesPath = initUITestMaps()
    }
    initSettings.connectivityMode = SKConnectivityMode.Online
    initSettings.mapDetailLevel = SKMapDetailLevel.Light;
    initSettings.showConsoleLogs = false
    SKMapsService.sharedInstance().initializeSKMapsWithAPIKey(apiKey, settings: initSettings)
    SKMapsService.sharedInstance().mapsVersioningManager.delegate = self
    
    AppDelegate.session = Session()

    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    window.backgroundColor = UIColor.whiteColor()
    window.makeKeyAndVisible()
    let nav = UINavigationController()
    nav.automaticallyAdjustsScrollViewInsets = false
    let guideController = GuideController(session: AppDelegate.session)
    guideController.edgesForExtendedLayout = .None // offset from navigation bar
    nav.viewControllers = [guideController]
    window.rootViewController = nav
    
    if NSProcessInfo.processInfo().arguments.contains("OFFLINEMAP") {
      print("Installing test-map before offline-mode")
      DownloadService.downloadCountry("Brunei", progressHandler: { progress in }) {
        print("Brunei download finished")
        guideController.loadCountryLists() // remove online countries from list
        guideController.tableView.accessibilityValue = "bruneiReady"
      }
      NetworkUtil.simulateOffline = true
    } else if NSProcessInfo.processInfo().arguments.contains("OFFLINE") {
      print("Simulating offline mode")
      NetworkUtil.simulateOffline = true
    }


    return true
  }
  
  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    print("applicationWillResignActive")
  }
  
  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    print("applicationDidEnterBackground")
  }
  
  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    print("applicationWillEnterForeground")
  }
  
  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    print("applicationDidBecomeActive")
    DownloadService.resumeDownloadsIfNecessary()    
  }
  
  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    print("applicationWillTerminate")
  }
  
  
  func mapsVersioningManagerLoadedMetadata(versioningManager: SKMapsVersioningManager!) {
    print("METADATA LOADED")
    if let callback = AppDelegate.metadataCallback {
      callback()
    }
  }
  
  func mapsVersioningManager(versioningManager: SKMapsVersioningManager!, loadedWithOfflinePackages packages: [AnyObject]!, updatablePackages: [AnyObject]!) {
    
    print("packages loaded: \(packages)")
  }
  
  func mapsVersioningManager(versioningManager: SKMapsVersioningManager!, loadedWithMapVersion currentMapVersion: String!) {
    print("Detected map version: \(currentMapVersion)")
  }
  
  enum AppMode {
    case TEST
    case BETA
    case RELEASE
  }
}

