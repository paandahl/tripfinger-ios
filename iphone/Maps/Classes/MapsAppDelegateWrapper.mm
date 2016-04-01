#import "MapsAppDelegateWrapper.h"
#include "MapsAppDelegate.h"
@implementation MapsAppDelegateWrapper
+ (UIViewController*)getMapViewController {
  return (UIViewController*)[MapsAppDelegate theApp].mapViewController;
}
@end

