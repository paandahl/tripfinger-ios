import UIKit
import Alamofire

@objc public class TripfingerAppDelegate: NSObject {
  
  static var serverUrl = "https://1-3-dot-tripfinger-server.appspot.com"
  static var mode = AppMode.BETA
  static var session: Session!

  public func applicationLaunched(application: UIApplication, delegate: UIApplicationDelegate, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> UIWindow {
    
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
    return window
  }
  
  enum AppMode {
    case TEST
    case BETA
    case RELEASE
  }
}