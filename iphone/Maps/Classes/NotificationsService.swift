//
//  NotificationsService.swift
//  Maps
//
//  Created by Preben Ludviksen on 14/07/16.
//  Copyright © 2016 Tripfinger AS. All rights reserved.
//

import Foundation

class NotificationsService {
  
  class func applicationLaunched(application: UIApplication, delegate: UIApplicationDelegate, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) {
//    let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
//    application.registerUserNotificationSettings(settings)
//    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(tokenRefreshNotification), name: kFIRInstanceIDTokenRefreshNotification, object: nil)
  }
  
  class func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
//    if notificationSettings.types != .None {
//      application.registerForRemoteNotifications()
//    }
  }
  
  class func applicationDidBecomeActive(application: UIApplication) {
//    connectToFcm()
  }
  
  class func applicationDidEnterBackground(application: UIApplication) {
//    FIRMessaging.messaging().disconnect()
//    print("Disconnected from FCM.")
  }
  
  class func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
//    let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
//    var tokenString = ""
//    
//    for i in 0..<deviceToken.length {
//      tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
//    }
//    
//    //Tricky line
//    FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.Unknown)
//    print("Device Token:", tokenString)
  }
  
  class func tokenRefreshNotification(notification: NSNotification) {
//    print("tokenRefreshNotification")
//    let refreshedToken = FIRInstanceID.instanceID().token()
//    print("InstanceID token: \(refreshedToken)")
//    connectToFcm()
  }
  
  class func connectToFcm() {
//    FIRMessaging.messaging().connectWithCompletion { error in
//      if error != nil {
//        print("Unable to connect with FCM. \(error)")
//      } else {
//        print("Connected to FCM.")
//        let refreshedToken = FIRInstanceID.instanceID().token()
//        print("refreshedToken: \(refreshedToken)")
//      }
//    }
  }
  
  class func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
                         fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    
    // Print message ID.
//    print("received notification: ")
//    print(userInfo)
//    if let aps = userInfo["aps"] as? [String: String] {
//      if let message = aps["alert"] {
//        let openUrl = userInfo["openUrl"]
//        let fromBackground = application.applicationState == .Inactive || application.applicationState == .Background
//        
//        if let openUrl = openUrl as? String {
//          if fromBackground {
//            UIApplication.sharedApplication().openURL(NSURL(string: openUrl)!)
//          } else {
//            sharedInstance.openUrl = openUrl
//            let alert = UIAlertView(title: "", message: message, delegate: sharedInstance, cancelButtonTitle: "No thanks", otherButtonTitles: "Read more")
//            alert.show()
//          }
//        }
//      }
//    }
//    
//    completionHandler(UIBackgroundFetchResult.NoData)
  }
}