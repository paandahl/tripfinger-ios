//
//  SKProxySettings.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, SKProxyType)
{
    SKProxyTypeNetwork = 0,
    SKProxyTypeSocks5
};

/** SKProxySettings is the model class for the proxy used by the framework for internet requests.
 */
@interface SKProxySettings : NSObject

/** The type of the proxy, regular or socks5.
 */
@property(nonatomic, assign) SKProxyType type;

/** The proxy IP.
 */
@property(nonatomic, strong) NSString *ip;

/** The port of the proxy.
 */
@property(nonatomic, assign) int port;

/** The mask of the server, only used in case of socks5 proxy.
 */
@property(nonatomic, strong) NSString *mask;

/** If YES, a user and password have to be provided for the proxy. If set to NO, the user and password will not be taken into consideration. By default, is no.
 */
@property(nonatomic, assign) BOOL useAutenthication;

/** The username for the proxy, if it is the case.
 */
@property(nonatomic, strong) NSString *user;

/** The password for the proxy, if it is the case.
 */
@property(nonatomic, strong) NSString *password;

/**A newly initialized SKProxySettings.
 */
+ (instancetype)proxySettings;

@end
