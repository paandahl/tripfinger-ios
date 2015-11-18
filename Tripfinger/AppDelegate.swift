//
//  AppDelegate.swift
//  Tripfinger
//
//  Created by Preben Ludviksen on 06/09/15.
//  Copyright (c) 2015 Preben Ludviksen. All rights reserved.
//

import UIKit
import SKMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SKMapVersioningDelegate {
  
  var window: UIWindow?
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    let URLCache = NSURLCache(memoryCapacity: 20 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: nil)
    NSURLCache.setSharedURLCache(URLCache)
    let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    print("Path: \(path[0])")
    
    let session = Session()
    
    let apiKey = "0511a5e338b00db8b426fb8ec0a7fb2ebd6816bb9324425d4edd9b726e40a3d5"
    let initSettings: SKMapsInitSettings = SKMapsInitSettings()
    initSettings.connectivityMode = SKConnectivityMode.Offline
    SKMapsService.sharedInstance().initializeSKMapsWithAPIKey(apiKey, settings: initSettings)
    SKMapsService.sharedInstance().mapsVersioningManager.delegate = self
    
    let navigationController = self.window!.rootViewController as! UINavigationController
    let rootController = navigationController.viewControllers[0] as! RootController
    rootController.session = session
    
    //        DataManager.getAttractionDateFromFileWithSuccess { (data) -> Void in
    //
    //            var attractions = [Attraction]()
    //            let json = JSON(data: data)
    //            if let attractionsJSON = json["attractions"].array {
    //                for attractionJSON in attractionsJSON {
    //                    if let title = attractionJSON["title"].string {
    //                        if let coordinateX = attractionJSON["coordinateX"].double {
    //                            if let coordinateY = attractionJSON["coordinateY"].double {
    //                                var attraction = Attraction(title: title, coordinateX: coordinateX, coordinateY: coordinateY)
    //                                if let image = attractionJSON["image"].string {
    //                                    attraction.image = UIImage(named: image)
    //                                }
    //                                attractions.append(attraction)
    //                            }
    //                        }
    //                    }
    //                }
    //            }
    //
    //            let tabBarController = self.window!.rootViewController as! UITabBarController
    //
    //            if let tabBarViewControllers = tabBarController.viewControllers {
    //
    //                var navigationController = tabBarViewControllers[2] as! UINavigationController
    //                let mapController = navigationController.viewControllers[0] as! MapDisplayViewController
    //                let forceTheViewToLoad = mapController.view
    //                mapController.attractions = attractions
    //                mapController.addAnnotations()
    //
    //                navigationController = tabBarViewControllers[1] as! UINavigationController
    //                let swipeController = navigationController.viewControllers[0] as! SwipeController
    //                swipeController.attractions = attractions
    //            }
    //        }
    
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
    
    print(packages)
  }
  
  
}

