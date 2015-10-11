//
//  SKMapVersioningDelegate.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SKMapsVersioningManager;

/** The delegate of the SKMapsVersioningManager must adopt the SKMapVersioningDelegate protocol. The SKMapVersioningDelegate protocol is used to receive callbacks related to map versioning.
 */
@protocol SKMapVersioningDelegate <NSObject>

@optional

/** Called when a new map version is available on the server.
 @param versioningManager The map versioning manager.
 @param currentMapVersion The map version the library currently uses.
 @param latestMapVersion  The latest available map version.
 */
- (void)mapsVersioningManager:(SKMapsVersioningManager *)versioningManager detectedNewAvailableMapVersion:(NSString *)latestMapVersion currentMapVersion:(NSString *)currentMapVersion;

/** Called when the user has map packages that can be updated.
 @param versioningManager The map versioning manager.
 @param packages The offline packages that are installed on the device.
 @param updatablePackages The installed offline packages that can be updated.
 */
- (void)mapsVersioningManager:(SKMapsVersioningManager *)versioningManager loadedWithOfflinePackages:(NSArray *)packages updatablePackages:(NSArray *)updatablePackages;

/** Called when the current map version is determined.
 @param versioningManager The map versioning manager.
 @param currentMapVersion The map version the library currently uses.
 */
- (void)mapsVersioningManager:(SKMapsVersioningManager *)versioningManager loadedWithMapVersion:(NSString *)currentMapVersion;

/** Called when the metadata of the map was successfully loaded.
 @param versioningManager The map versioning manager.
 */
- (void)mapsVersioningManagerLoadedMetadata:(SKMapsVersioningManager *)versioningManager;

@end
