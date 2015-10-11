//
//  SKMapsService.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "SKOfflinePackagesManager.h"
#import "SKDefinitions.h"
#import "SKMapsVersioningManager.h"
#import "SKTilesCacheManager.h"

extern NSString *const kSKMapsLibraryInitialisedNotification;

@class SKMapsInitSettings;
@class SKProxySettings;

/** SKMapsService class provides support for general settings and management that concerns the whole SKMaps Framework behavior. In order to be used, the library needs several metadata files that will be downloaded on the first initialization. When this is done, a kSKMapsMetadataLoadedNotification NSNotification is posted.
 */
@interface SKMapsService : NSObject

/** Returns the singleton SKMapsService instance.
 */
+ (instancetype)sharedInstance;

/** Initializes the SKMaps Framework with an API key and settings. Should be called once, usually when the application starts ( application:didFinishLaunchingWithOptions: method from the AppDelegate ).
 @param apiKey The unique developer API key. If the apiKey is not valid, the library will not be usable.
 @param initSettings The initial configuration. For further details check the SKMapsInitSettings documentation. If nil, default settings wil be used.
 */
- (void)initializeSKMapsWithAPIKey:(NSString *)apiKey settings:(SKMapsInitSettings *)initSettings;

#pragma mark - Managers

/** The manager that handles offline map packages. For further details check the SKOfflinePackagesManager documentation.
 */
@property(nonatomic, readonly, strong) SKOfflinePackagesManager *packagesManager;

/** The manager that handles the tiles cache. For further details check the SKTilesCacheManager documentation.
 */
@property(nonatomic, readonly, strong) SKTilesCacheManager *tilesCacheManager;

/** The manager that handles the maps versioning. For further details check the SKMapsVersioningManager documentation.
 */
@property(nonatomic, readonly, strong) SKMapsVersioningManager *mapsVersioningManager;

#pragma mark - Connectivity

/** The framework's general connectivity mode ( online or offline ). If set to offline, no server requests will be sent and no data will be downloaded. The default value is SKConnectivityModeOnline.
 */
@property(nonatomic, assign) SKConnectivityMode connectivityMode;

/** The proxy that will be used to download data. If nil, any proxy previously set will be disabled.
 */
@property(nonatomic, strong) SKProxySettings *proxySettings;

#pragma mark - API Key

/** The developer API key used to initialize the framework.
 */
@property(nonatomic, readonly, strong) NSString *apiKey;

/** The obfuscated developer API key.
 */
@property(nonatomic, readonly, strong) NSString *obfuscatedAPIKey;

#pragma mark - Framework version

/** Version of the framework in use.
 */
@property(nonatomic, readonly, strong) NSString *frameworkVersion;

@end
