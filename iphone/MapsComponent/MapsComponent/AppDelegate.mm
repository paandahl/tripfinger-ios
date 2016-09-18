//
//  AppDelegate.m
//  MapsComponentTest
//
//  Created by Preben Ludviksen on 15/09/16.
//  Copyright © 2016 Tripfinger AS. All rights reserved.
//

#import "AppDelegate.h"
#import "EAGLView.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
{
  ViewController * iMapViewController;
}
+ (AppDelegate *)theApp
{
  return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  NSLog(@"didFinishLaunchingWithOptions()");
  // Override point for customization after application launch.
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  NSLog(@"applicationWillEnterForeground()");
  [(EAGLView *)self.mapViewController.view initialize];

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  NSLog(@"applicationDidBecomeActive()");
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (ViewController *)mapViewController
{
  if (iMapViewController == nil) {
    NSLog(@"instantiating MapViewController");
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Mapsme" bundle: nil];
    iMapViewController = [storyboard instantiateViewControllerWithIdentifier:@"mapViewController"];
  }
  return iMapViewController;
}


@end
