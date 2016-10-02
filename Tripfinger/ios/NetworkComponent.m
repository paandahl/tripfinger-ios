#import "NetworkComponent.h"
#import <AFNetworking/AFNetworking.h>

@implementation NetworkComponent

+ (void)saveDataFromUrl:(NSString*)url toPath:(NSURL*)destinationPath callback:(void(^)())callback {
  NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
  AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
  
  NSURL *URL = [NSURL URLWithString:url];
  NSURLRequest *request = [NSURLRequest requestWithURL:URL];
  
  NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
    return destinationPath;
  } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
    callback();
  }];
  [downloadTask resume];
}

@end