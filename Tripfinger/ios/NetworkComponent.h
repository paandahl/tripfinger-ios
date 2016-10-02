#import <Foundation/Foundation.h>

@interface NetworkComponent : NSObject
+ (void)saveDataFromUrl:(NSString*)url toPath:(NSURL*)destinationPath callback:(void(^)())callback;
@end