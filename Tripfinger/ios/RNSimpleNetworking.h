#import <Foundation/Foundation.h>
#import "RCTBridgeModule.h"

@interface RNSimpleNetworking : NSObject <RCTBridgeModule, NSURLSessionDownloadDelegate>
//+ (NSUInteger)saveDataFromUrl:(NSString*)url toPath:(NSURL*)destinationPath requestMethod:(NSString*)method body:(NSString*)body onSuccess:(void(^)())successCalback onError:(void(^)(NSString*))errorCallback;
@end
