#import <Foundation/Foundation.h>
#import "RCTBridgeModule.h"

@interface MWMOpeningHours : NSObject <RCTBridgeModule>

  + (NSDictionary*)createOpeningHoursDict:(NSString*)timeString;

@end
