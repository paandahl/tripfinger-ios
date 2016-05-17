#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SwiftBridge.h"

@interface MapsAppDelegateWrapper : NSObject
+ (UIViewController*)getMapViewController;
+ (void)openPlacePage:(TripfingerEntity *)entity;
+ (void)openSearch;
+ (void)openMapSearchWithQuery:(NSString*)query;
+ (void)openDownloads:(NSString*)countryId navigationController:(UINavigationController*)navigationController;
+ (void)navigateToRect:(CLLocationCoordinate2D)botLeft topRight:(CLLocationCoordinate2D)topRight;
+ (void)selectListing:(TripfingerEntity *)entity;
+ (void)saveBookmark:(TripfingerEntity *)entity;
+ (void)deleteBookmark:(TripfingerEntity *)entity;
@end
