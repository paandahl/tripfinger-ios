//
//  SKTilesCacheManager.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>

/** SKMapsManager's tiles cache manager. Should not be explicitly allocated.
 Provides advanced management for the tiles caching mechanism.
 */
@interface SKTilesCacheManager : NSObject

/** Current size of the map cache already on the device, in bytes.
 */
@property(nonatomic, readonly, assign) unsigned long long cacheSize;

/** Limit of the cache size, in bytes.
 */
@property(nonatomic, assign) unsigned long long cacheLimit;

/** Deletes all the map related data from the disk, including cache from online usage, offline map packets, metadata, textures.
 When updating an application, this can be called on the first start of the updated app to clear the maps from the previous version. All the offline map packages from previous instalation will have to be reinstalled.
 Call the deleteAllMapsDataWithCachesPath: method before any other SKMapsService usage ( even  before initializeSKMapsWithAPIKey:settings: method ), otherwise the library will have an unexpected behavior.
 @param cachesPath The path to the map caches, if previously set using SKMapsInitSettings. Otherwise, just pass nil and the cache from the default path will be deleted.
 @return Success or failure of maps data deletion.
 */
- (BOOL)deleteAllMapsDataWithCachesPath:(NSString *)cachesPath;

/** Deletes all the tiles cached when using online maps, releasing disk space.
 */
- (void)deleteAllCache;

/** Deletes map tiles cached when using online maps older than a certain time, releasing disk space.
 @param seconds Tiles older than _seconds_ will be deleted.
 */
- (void)deleteCacheOlderThan:(long)seconds;

@end
