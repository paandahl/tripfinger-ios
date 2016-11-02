#import "RNSimpleNetworking.h"
#import "RNFileSystem.h"
#import "RNSimpleNetworkingEmitter.h"

@implementation RNSimpleNetworking {
  NSURLSessionConfiguration *configuration;
  NSURLSession *urlSession;
  NSMutableDictionary* downloadTaskDict;
}

+ (instancetype)sharedInstance
{
  static RNSimpleNetworking *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[RNSimpleNetworking alloc] init];
  });
  return sharedInstance;
}

- (id)init {
  self = [super init];
  configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
  urlSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
  downloadTaskDict = [[NSMutableDictionary alloc] init];
  return self;
}

- (NSNumber*)downloadFile:(NSString*)url toPath:(NSString*)relativePath storage:(NSString*)storage requestMethod:(NSString*)method body:(NSString*)body {
  NSURL *nsUrl = [NSURL URLWithString:url];
  NSMutableURLRequest *downloadRequest = [NSMutableURLRequest requestWithURL:nsUrl];
  [downloadRequest setHTTPMethod:method];
  if ([method isEqual: @"POST"]) {
    [downloadRequest setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
  }

  NSURLSessionDownloadTask *downloadTask = [urlSession downloadTaskWithRequest:downloadRequest];
  [downloadTask resume];
  NSNumber *taskIdentifier = [NSNumber numberWithUnsignedInteger:[downloadTask taskIdentifier]];
  NSDictionary *taskHolder = @{@"task": downloadTask,
                               @"relativePath": relativePath,
                               @"storage": storage};
  [downloadTaskDict setObject:taskHolder forKey:taskIdentifier];
  return taskIdentifier;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
  
  NSNumber *taskIdentifier = [NSNumber numberWithUnsignedInteger:[downloadTask taskIdentifier]];
  double progress = totalBytesWritten / totalBytesExpectedToWrite;
  NSNumber *progressNumber = [NSNumber numberWithDouble:progress];
  NSDictionary *eventData = @{@"taskId": taskIdentifier,
                              @"progress": progressNumber};
  [[NSNotificationCenter defaultCenter] postNotificationName:kDownloadProgress object:self userInfo:eventData];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
  
  NSNumber *taskIdentifier = [NSNumber numberWithUnsignedInteger:[downloadTask taskIdentifier]];
  NSDictionary* taskHolder = [downloadTaskDict objectForKey:taskIdentifier];
  NSString* relativePath = [taskHolder objectForKey:@"relativePath"];
  NSString* storage = [taskHolder objectForKey:@"storage"];
  [RNFileSystem moveFileFromUrl:location toRelativePath:relativePath inStorage:storage];
  
  NSDictionary *eventData = @{@"taskId": taskIdentifier,
                              @"status": @"success"};
  [[NSNotificationCenter defaultCenter] postNotificationName:kDownloadStatusChanged object:self userInfo:eventData];
  [downloadTaskDict removeObjectForKey:taskIdentifier];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
  if (error != nil) {
    NSNumber *taskIdentifier = [NSNumber numberWithUnsignedInteger:[task taskIdentifier]];
    NSString *url = [[[task originalRequest] URL] absoluteString];
    NSString* errorMessage = [[[error localizedDescription] stringByAppendingString:@": "] stringByAppendingString:url];
    NSDictionary *eventData = @{@"taskId": taskIdentifier,
                                @"status": @"failed",
                                @"error": errorMessage};
    [[NSNotificationCenter defaultCenter] postNotificationName:kDownloadStatusChanged object:self userInfo:eventData];
  }
}

- (void)cancelRequest:(NSUInteger)taskIdentifier {
  NSURLSessionDownloadTask* task = downloadTaskDict[[NSNumber numberWithUnsignedInteger:taskIdentifier]];
  [task cancel];
}

RCT_EXPORT_MODULE();


RCT_EXPORT_METHOD(downloadFile:(NSString*)url relativePath:(NSString*)relativePath toStorage:(NSString*)storage requestMethod:(NSString*)method body:(NSString*)body overwrite:(BOOL)overwrite resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  BOOL fileExists = [RNFileSystem fileExists:relativePath inStorage:storage];
  BOOL folderExists = [RNFileSystem directoryExists:relativePath inStorage:storage];
  NSNumber *taskIdentifier;
  if ((fileExists || folderExists) && !overwrite) {
    NSLog(@"Found file: %@", relativePath);
    taskIdentifier = 0;
  } else {
    NSLog(@"Downloading url: %@", url);
    RNSimpleNetworking *networking = [RNSimpleNetworking sharedInstance];
    taskIdentifier = [networking downloadFile:url toPath:relativePath storage:storage requestMethod:method body:body];
  }
  NSString *absolutePath = [RNFileSystem absolutePath:relativePath inStorage:storage];
  resolve(@{@"taskId": taskIdentifier, @"absolutePath": absolutePath});
}

@end
