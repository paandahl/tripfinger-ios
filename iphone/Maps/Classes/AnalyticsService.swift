import Foundation
import FirebaseAnalytics

class AnalyticsService {
  
  static var disabled = false
  
  class func applicationLaunched(application: UIApplication, delegate: UIApplicationDelegate, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) {
    let launchArgs = NSProcessInfo.processInfo().arguments
    let statisticsEnabled = NSUserDefaults.standardUserDefaults().boolForKey("statisticsEnabled")
    if (!statisticsEnabled) || launchArgs.contains("DISABLE_STATS") || launchArgs.contains("TEST") {
      FIRAnalyticsConfiguration.sharedInstance().setAnalyticsCollectionEnabled(false)
      disabled = true
      print("analytics was disabled")
    } else {
      FIRApp.configure()
      print("myuuid: \(UniqueIdentifierService.uniqueIdentifier())")
      FIRAnalytics.setUserPropertyString(UniqueIdentifierService.uniqueIdentifier(), forName: "device_id")
      FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
      print("analytics was enabled")
    }
  }
  
  class func applicationDidBecomeActive(application: UIApplication) {
    if !disabled {
      FBSDKAppEvents.activateApp()
    }
  }
  
  class func application(application: UIApplication, openURL url: NSURL, sourceApplication: NSString, annotation: AnyObject) -> Bool {
    return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication as String, annotation: annotation)
  }
  
  class func logAppMode(mode: TripfingerAppDelegate.AppMode) {
    if !disabled {
      let analyticsDraftMode = (mode == .DRAFT) ? "BETA" : String(mode)
      FIRAnalytics.setUserPropertyString(analyticsDraftMode, forName: "app_mode")
      print("appMode: \(mode)")
    }
  }
  
  class func logSelectedRegion(region: Region) {
    if !disabled {
      FIRAnalytics.logEventWithName(kFIREventSelectContent, parameters: [
        kFIRParameterContentType: "region",
        kFIRParameterItemID: region.getName()
        ])
    }
  }
  
  class func logSelectedListing(listing: Listing) {
    if !disabled {
      FIRAnalytics.logEventWithName(kFIREventSelectContent, parameters: [
        kFIRParameterContentType: "listing",
        kFIRParameterItemID: listing.item().name
        ])
    }
  }
  
  class func logSelectedSection(section: GuideText, region: Region? = nil) {
    if !disabled {
      let itemId: String
      if let region = region {
        itemId = region.getName() + ": " + section.getName()
      } else {
        itemId = section.getName() + "(\(section.getId()))"
      }
      
      FIRAnalytics.logEventWithName(kFIREventSelectContent, parameters: [
        kFIRParameterContentType: "section",
        kFIRParameterItemID: itemId
        ])
    }
  }
  
  class func logSelectedCategory(categoryDescription: GuideText, region: Region) {
    if !disabled {
      FIRAnalytics.logEventWithName(kFIREventSelectContent, parameters: [
        kFIRParameterContentType: "category",
        kFIRParameterItemID: region.getName() + ": " + categoryDescription.getCategory().entityName
        ])
    }
  }
  
  class func logDownloadFirstCountry(country: Region) {
    if !disabled {
      FIRAnalytics.logEventWithName("first_download", parameters: [
        "country": country.getName()
        ])
    }
  }
  
  class func logDownloadCountry(downloadId: String) {
    if !disabled {
      FIRAnalytics.logEventWithName("download_country", parameters: [
        "name": downloadId
        ])      
    }
  }
}