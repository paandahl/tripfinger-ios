//
//  SKMapsInitSettings.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKDefinitions.h"

@class SKMapViewStyle, SKProxySettings;

static NSString *const kDefaultCachesFolderName = @"maps";

/** SKMapsInitSettings stores settings for customized SKMaps framework initialization.
 */
@interface SKMapsInitSettings : NSObject

/** The initial connectivity mode. If set to offline, no server requests will be performed by the library. The default value is SKConnectivityModeOnline.
 */
@property(nonatomic, assign) SKConnectivityMode connectivityMode;

/** The detail level of the map. Light maps don't contain building footprints and map POIs. By default is set to SKMapDetailLevelFull.
 */
@property(nonatomic, assign) SKMapDetailLevel mapDetailLevel;

/** Initial style of SKMapView instances. By default, the day style will be used.
 */
@property(nonatomic, strong) SKMapViewStyle *mapStyle;

/** The path where the map files (tiles, textures, caches) will be stored. The default path is the application's "\Library\Caches\maps" folder.
 */
@property(nonatomic, strong) NSString *cachesPath;

/** Enables / disables the logging to console and to file. Logs are stored in the application's Documents folder. By default the logs are enabled. For a release to AppStore this should be set to NO.
 */
@property(nonatomic, assign) BOOL showConsoleLogs;

/** The initial proxy settings used by the framework for internet requests.
 */
@property(nonatomic, strong) SKProxySettings *proxySettings;

/** A newly initialized SKMapsInitSettings.
 */
+ (instancetype)mapsInitSettings;

@end
