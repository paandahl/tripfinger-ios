//
//  SKMapsVersioningManager.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKDefinitions.h"

extern NSString *const kSKMapsVersionFileDownloadSuccessNotification;
extern NSString *const kSKMapsVersionFileDownloadTimeOutNotification;
extern NSString *const kSKMapsMetadataLoadedNotification;

@protocol SKMapVersioningDelegate;

/** Provides advanced management for handling different map versions. Should not be explicitly allocated.
 On the initialization of the framework, a request is sent for downloading a file containing all available map versions. The kSKMapsVersionFileDownloadSuccessNotification notification is sent if the request is successful and kSKMapsVersionFileDownloadTimeOutNotification otherwise.
 */
@interface SKMapsVersioningManager : NSObject

/** The delegate that must conform to SKMapVersioningDelegate protocol, used for receiving callbacks related to map versioning.
 */
@property(nonatomic, weak) id<SKMapVersioningDelegate> delegate;

/** The version of the maps currently used by the framework.
 On a fresh install the value is the latest from the versions list.
 */
@property(nonatomic, readonly, strong) NSString *currentMapVersion;

/** The list of map versions the user had installed, sorted from latest to oldest. This list does not coincide with availableMapVersions, since that list contains available versions on the server.
 This property stores only the versions that were installed on the device and the first one is the current version.
 */
@property(nonatomic, readonly, strong) NSArray *localMapVersions;

/** The list of available map versions on the server. The first object of the list is the latest version on the server.
 This list is updated when the user checks for new versions using checkNewVersion if new versions appeared since the last update. The list consists of elements of SKVersionInformation type.
 The versions for the maps can be accessed using the "version" property of SKVersionInformation objects.
 */
@property(nonatomic, readonly, strong) NSArray *availableMapVersions;

/** Updates to the version specified by the version parameter. The version sent as parameter is the version which will be used as the currentMapVersion. This version should be taken from the availableMapVersions.
 @param version The version to which the framework tries to update ("version" property of a SKVersionInformation)
 @return YES if updated with success, NO otherwise.
 */
- (BOOL)updateToVersion:(NSString *)version;

/** Checks for a new map version on the server. By default this method is called when initializing the SKMaps framework (application's start). This method allows the client iOS applications to check periodically for updates.
 In order to check if new versions are available on the server, the availableMapVersions should be interrogated after this method is called and the kSKMapsVersionFileDownloadSuccessNotification is received.
 */
- (void)checkNewVersion;

/** The metaDataDownloadedStatus property verifies the meta file downloaded status for the current map version.
 */
@property(nonatomic, assign, readonly) SKMetaDataDownloadStatus metaDataDownloadedStatus;

/**Initializer.
 @param connectivityMode Indicates the type of the connectivity mode. (Online or offline)
 */
- (instancetype)initWithConnectivityMode:(SKConnectivityMode)connectivityMode;

@end
