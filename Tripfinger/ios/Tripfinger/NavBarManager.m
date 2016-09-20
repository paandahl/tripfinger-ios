#import "RCTBridgeModule.h"
#import <UIKit/UIKit.h>

@interface NavBarManager : NSObject <RCTBridgeModule>
@end

@implementation NavBarManager

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(setNavBarHidden:(BOOL *)hidden)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    UIViewController * root = [UIApplication sharedApplication].delegate.window.rootViewController;
    UINavigationController * nav = root.childViewControllers[0];
    [nav setNavigationBarHidden:hidden animated:YES];
  });
}

RCT_EXPORT_METHOD(toggleNavBarHidden)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    UIViewController * root = [UIApplication sharedApplication].delegate.window.rootViewController;
    UINavigationController * nav = root.childViewControllers[0];
    [nav setNavigationBarHidden:!nav.navigationBarHidden animated:YES];
  });
}

@end