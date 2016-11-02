#import <Foundation/Foundation.h>
#import "RCTBridgeModule.h"

@interface UniqueIdentifier : NSObject <RCTBridgeModule>

+ (NSString*)getIdentifier;

@end
