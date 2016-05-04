#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SwiftBridge.h"

@interface MapsAppDelegateWrapper : NSObject
+ (UIViewController*)getMapViewController;
+ (void)openPlacePage:(TripfingerEntity *)entity;
@end
