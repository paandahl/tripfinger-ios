#import "RNSimpleNetworkingEmitter.h"

@implementation RNSimpleNetworkingEmitter

RCT_EXPORT_MODULE();

NSString *const kDownloadStatusChanged = @"RNSimpleNetworkingEmitter/downloadStatusChanged";
NSString *const kDownloadProgress = @"RNSimpleNetworkingEmitter/downloadProgress";

- (NSDictionary<NSString *, NSString *> *)constantsToExport {
  return @{@"DOWNLOAD_STATUS_CHANGED": kDownloadStatusChanged,
           @"DOWNLOAD_PROGRESS": kDownloadProgress};
}

- (NSArray<NSString *> *)supportedEvents {
  return @[kDownloadStatusChanged, kDownloadProgress];
}

- (void)startObserving {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(downloadStatusChanged:)
                                               name:kDownloadStatusChanged
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(downloadProgress:)
                                               name:kDownloadProgress
                                             object:nil];
}

- (void)stopObserving {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)downloadStatusChanged:(NSNotification *)notification {
  [self sendEventWithName:kDownloadStatusChanged body:notification.userInfo];
}

- (void)downloadProgress:(NSNotification *)notification {
  [self sendEventWithName:kDownloadProgress body:notification.userInfo];
}

@end
