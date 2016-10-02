#import "RCTBridgeModule.h"
#import "NetworkComponent.h"

@interface FSComponent : NSObject <RCTBridgeModule>
@end

@implementation FSComponent

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(downloadFile:(NSString *)url withFileName:(NSString *)fileName callback:(RCTResponseSenderBlock)callback)
{
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSURL *documentsDir = [fileManager URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
  NSURL *filePath = [documentsDir URLByAppendingPathComponent:fileName];
  if ([fileManager fileExistsAtPath:[filePath path]]) {
    NSLog(@"File existed and download was skipped: %@", [filePath path]);
    callback(@[[NSNull null], [filePath path]]);
  } else {
    NSLog(@"Downloading file: %@", fileName);
    [NetworkComponent saveDataFromUrl:url toPath:filePath callback:^{
      NSLog(@"Downloaded file: %@", fileName);
      callback(@[[NSNull null], [filePath path]]);
    }];
  }
  
}

@end