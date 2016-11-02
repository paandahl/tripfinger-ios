#import "UniqueIdentifier.h"
#import "KeychainWrapper.h"
#import <Security/Security.h>

@implementation UniqueIdentifier

RCT_EXPORT_MODULE();

+ (NSString*)getIdentifier {
  KeychainWrapper *keychain = [[KeychainWrapper alloc] init];
  NSString *uniqueIdentifier = [keychain myObjectForKey:(__bridge id)kSecValueData];
  if (uniqueIdentifier != nil) {
    return uniqueIdentifier;
  } else {
    NSString *idString = [[NSUUID UUID] UUIDString];
    [keychain mySetObject:idString forKey:(__bridge id)kSecValueData];
  }
  return uniqueIdentifier;
}

RCT_EXPORT_METHOD(getIdentifier:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  resolve([UniqueIdentifier getIdentifier]);
}

@end
