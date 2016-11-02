/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "AppDelegate.h"

#import "RCTBundleURLProvider.h"
#import "RCTRootView.h"
#import "UIImage+initWithColor.h"
#import "MWMMapView.h"
#import "UniqueIdentifier.h"

@implementation AppDelegate

-(CGFloat)scaled:(CGFloat)f
{
  return f / 255.;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  NSString *uniqueIdentifer = [UniqueIdentifier getIdentifier];
  NSLog(@"Device uuid: %@", uniqueIdentifer);
  NSURL *jsCodeLocation;

  jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index.ios" fallbackResource:nil];

  RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                      moduleName:@"Tripfinger"
                                               initialProperties:nil
                                                   launchOptions:launchOptions];
  rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];
  
  UIColor * primary = [UIColor colorWithRed:[self scaled:36.] green:[self scaled:182.] blue:[self scaled:243.] alpha:1.0];
  UIImage *gradientImage44 = [UIImage imageWithColor:primary];
  UIImage *gradientImage32 = [UIImage imageWithColor:primary];
  [[UINavigationBar appearance] setBackgroundImage:gradientImage44 forBarMetrics:UIBarMetricsDefault];
  [[UINavigationBar appearance] setBackgroundImage:gradientImage32 forBarMetrics:UIBarMetricsLandscapePhone];
  [[UINavigationBar appearance] setBarStyle:UIBarStyleDefault];
  
  [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
  [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
  
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];
  dispatch_async(dispatch_get_main_queue(), ^{
    MWMMapView * mapView = [MWMMapView sharedInstance];
    mapView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [mapView layoutSubviews];
  });
  return YES;
}

+ (void)setBookmarks:(NSArray*)bookmarks {
  Framework & f = GetFramework();
  map<m2::PointD, BookmarkData> bookmarkMap;
  for (NSDictionary *bookmark in bookmarks) {
    NSNumber * latitude = bookmark[@"latitude"];
    NSNumber * longitude = bookmark[@"longitude"];
    NSString * databaseKey = bookmark[@"databaseKey"];
    NSString * name = bookmark[@"name"];
    NSString * notes = bookmark[@"notes"];
    
    m2::PointD coord = MercatorBounds::FromLatLon(latitude.doubleValue, longitude.doubleValue);
    BookmarkData bookmarkData([name UTF8String], f.GetBookmarkManager().LastEditedBMType(), "");
    bookmarkData.SetDatabaseKey([databaseKey UTF8String]);
    if (notes != nil) {
      bookmarkData.SetDescription([notes UTF8String]);
    }
    bookmarkMap[coord] = bookmarkData;
  }
  f.SetBookmarks(bookmarkMap);
}
 
- (void)applicationWillResignActive:(UIApplication *)application
{
  NSLog(@"applicationWillResignActive");
  MWMMapView * mapView = [MWMMapView sharedInstance];
  [mapView onGetFocus: NO];
  GetFramework().SetRenderingEnabled(false);
}
  
- (void)applicationDidBecomeActive:(UIApplication *)application
{
  NSLog(@"applicationDidBecomeActive");
  if (application.applicationState == UIApplicationStateBackground)
    return;
  MWMMapView * mapView = [MWMMapView sharedInstance];
  [mapView onGetFocus: YES];
  GetFramework().SetRenderingEnabled(true);
}

- (void)onTerminate
{
}

@end
