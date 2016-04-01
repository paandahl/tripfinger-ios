import UIKit

@objc public class TripfingerAppDelegate: NSObject {
  
  public var window: UIWindow?

  public func applicationLaunched(application: UIApplication, delegate: UIApplicationDelegate, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> UIWindow {
    
    print("didFinishLaunchingWithOptions!!")
    let window = UIWindow(frame: UIScreen.mainScreen().bounds)
    window.backgroundColor = UIColor.whiteColor()
    window.makeKeyAndVisible()
    let nav = UINavigationController()
    nav.automaticallyAdjustsScrollViewInsets = false
    let regionController = GuideViewController()
    regionController.edgesForExtendedLayout = .None // offset from navigation bar
    nav.viewControllers = [regionController]
    window.rootViewController = nav
    return window
  }
}