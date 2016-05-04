#import "MapsAppDelegateWrapper.h"
#import "MapsAppDelegate.h"
#import "MapViewController.h"
#import "MWMMapViewControlsManager.h"

@implementation MapsAppDelegateWrapper
+ (UIViewController*)getMapViewController {
  return (UIViewController*)[MapsAppDelegate theApp].mapViewController;
}

+ (void)openPlacePage:(TripfingerEntity *)entity {
  [[MapsAppDelegate theApp].mapViewController.controlsManager showPlacePageWithEntityFullscreen:entity];
}

@end

