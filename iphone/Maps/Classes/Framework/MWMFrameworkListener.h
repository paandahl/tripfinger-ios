#import "MWMFrameworkObservers.h"

#include "platform/location.hpp"

@interface MWMFrameworkListener : NSObject

+ (MWMFrameworkListener *)listener;
+ (void)addObserver:(id<MWMFrameworkObserver>)observer;
+ (void)removeObserver:(id<MWMFrameworkObserver>)observer;

- (instancetype)init __attribute__((unavailable("call +listener instead")));
- (instancetype)copy __attribute__((unavailable("call +listener instead")));
- (instancetype)copyWithZone:(NSZone *)zone __attribute__((unavailable("call +listener instead")));
+ (instancetype)alloc __attribute__((unavailable("call +listener instead")));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable("call +listener instead")));
+ (instancetype)new __attribute__((unavailable("call +listener instead")));
+ (void)updateDownloadProgress:(string)countryId progress:(TLocalAndRemoteSize)progress;
+ (void)updateDownloadState:(string)countryId;

@end
