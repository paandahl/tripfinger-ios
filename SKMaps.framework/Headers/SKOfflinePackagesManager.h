//
//  SKOfflinePackagesManager.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKDefinitions.h"

@class SKMapPackageDownloadInfo;

/** SKMapsManager's offline packages manager. Should not be explicitly allocated.
 Handles offline map packages management.
 */
@interface SKOfflinePackagesManager : NSObject

/**Library's installed offline packages. An array of SKMapPackage objects.
 */
@property(nonatomic, readonly, strong) NSArray *installedOfflineMapPackages;

/**An array of SKMapPackage objects with installed offline packages that are not at the latest available map version. Check SKMapsVersioningManager for more versioning information.
 */
@property(nonatomic, readonly, strong) NSArray *outdatedOfflineMapPackages;

/**Base URL for map tiles and offline packages download.
 */
@property(nonatomic, readonly, strong) NSString *mapsDownloadBasePath;

#pragma mark - Offline packages management

/** Adds a downloaded offline map package to the library. Adding an offline map package should be done only once in the lifetime of the app for a package, unless it's deleted.
 The downloaded files will be moved in the SKMaps' file structure. No other manual management of the files is needed after adding the package.
 This method should be used for installing downloadable content. For preinstalled maps, use the PreinstalledMaps folder included in the SKMaps.bundle.
 @param packageName The name of the package. Ex: "RO" , "DE", etc. , without any extension.
 @param containingFolderPath The path to the folder where the files are located. Expected files :
 
 - .skm file ( map data file ).
 - .ngi & .ngi.dat namebrowser files, used for offline searches. Usually downloaded as an archived package.
 - .txg file (texture file).
 
 @return SKAddPackageResult mask representing the result of adding the package.
 */
- (SKAddPackageResult)addOfflineMapPackageNamed:(NSString *)packageName inContainingFolderPath:(NSString *)containingFolderPath;

/** Deletes an offline map package. When a package is added, the files are moved to the SKMaps' file structure. On deletion, the files on the disk are also deleted.
 @param packageName The name of the package to be deleted. Ex: RO , DE, etc. , without any extension.
 @return YES on success, NO on failure.
 */
- (BOOL)deleteOfflineMapPackageNamed:(NSString *)packageName;

/**Checks if an offline map file ( .skm file ) is valid. Can be used before installing offline map packages.
 @param path Path of the .skm file.
 @return YES for a valid package, NO otherwise.
 */
- (BOOL)validateMapFileAtPath:(NSString *)path;

#pragma mark - URLs

/** URL of the maps XML for the given version. The version has to be a string ("version" property of a SKVersionInformation).
 @param version Map version for the maps XML. If the parameter is nil, the current version of the map will be used.
 @return The URL to the maps XML for the desired version.
 */
- (NSString *)mapsXMLURLForVersion:(NSString *)version;

/** URL of the maps JSON for the given version. The version has to be a string ("version" property of a SKVersionInformation).
 @param version Map version for the maps JSON. If the parameter is nil, the current version of the map will be used.
 @return The URL to the maps JSON for the desired version.
 */
- (NSString *)mapsJSONURLForVersion:(NSString *)version;

/** Download information ( required URLs ) for an offline map package code.
 @param packageCode The package code (RO, DE, etc.) used to generate the package download info.
 */
- (SKMapPackageDownloadInfo *)downloadInfoForPackageWithCode:(NSString *)packageCode;

@end
