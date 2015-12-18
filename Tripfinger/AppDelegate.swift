import UIKit
import SKMaps
import BrightFutures

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SKMapVersioningDelegate {
  
  var window: UIWindow?
  var mapVersionFilePromise = Promise<String, NoError>()
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    let URLCache = NSURLCache(memoryCapacity: 20 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: nil)
    NSURLCache.setSharedURLCache(URLCache)
    let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    print("Path: \(path[0])")
    
    let apiKey = "0511a5e338b00db8b426fb8ec0a7fb2ebd6816bb9324425d4edd9b726e40a3d5"
    let initSettings: SKMapsInitSettings = SKMapsInitSettings()
    initSettings.connectivityMode = SKConnectivityMode.Online
    initSettings.mapDetailLevel = SKMapDetailLevel.Light;
    SKMapsService.sharedInstance().initializeSKMapsWithAPIKey(apiKey, settings: initSettings)
    SKMapsService.sharedInstance().mapsVersioningManager.delegate = self
    
    let session = Session()
    session.currentItemId = "region-brussels"
    session.mapVersionFileDownloaded = mapVersionFilePromise.future

    let navigationController = self.window!.rootViewController as! UINavigationController
    let rootController = navigationController.viewControllers[0] as! RootController
    rootController.session = session
    
    return true
  }
  
  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  
  func mapsVersioningManagerLoadedMetadata(versioningManager: SKMapsVersioningManager!) {
  }
  
  func mapsVersioningManager(versioningManager: SKMapsVersioningManager!, loadedWithOfflinePackages packages: [AnyObject]!, updatablePackages: [AnyObject]!) {
    
    print("packages loaded: \(packages)")
  }
  
  func mapsVersioningManager(versioningManager: SKMapsVersioningManager!, loadedWithMapVersion currentMapVersion: String!) {
    mapVersionFilePromise.success("Downloaded")
  }

  
}

