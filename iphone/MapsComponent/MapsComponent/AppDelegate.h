//
//  AppDelegate.h
//  MapsComponentTest
//
//  Created by Preben Ludviksen on 15/09/16.
//  Copyright © 2016 Tripfinger AS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, readwrite) BOOL isDaemonMode;

+ (AppDelegate *)theApp;

@end

