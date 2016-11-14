#import "MWMSearchEmitter.h"

@implementation MWMSearchEmitter

RCT_EXPORT_MODULE();

NSString *const kSearchResults = @"MWMSearchEmitter/searchResults";

- (NSDictionary<NSString *, NSString *> *)constantsToExport {
  return @{@"SEARCH_RESULTS": kSearchResults};
}

- (NSArray<NSString *> *)supportedEvents {
  return @[kSearchResults];
}

- (void)startObserving {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(searchResults:)
                                               name:kSearchResults
                                             object:nil];
}

- (void)stopObserving {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)searchResults:(NSNotification *)notification {
  [self sendEventWithName:kSearchResults body:notification.userInfo];
}

@end
