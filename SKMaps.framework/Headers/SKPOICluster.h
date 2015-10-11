//
//  SKAnnotationClusterInformation.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Stores information about the selected POI cluster.
 */
@interface SKPOICluster : NSObject

/** An array of NSNumber objects. The annotation ID's for the custom POI's grouped by the cluster.
 */
@property(nonatomic, strong) NSArray *customPOIList;

/** An array of SKMapPOI objects. The map POI object's grouped by the cluster.
 */
@property(nonatomic, strong) NSArray *mapPOIList;

/** If the cluster will be placed on a custom POI this will be set to YES. Note that the cluster will pe placed on the first annotation/mapPOI from the corresponding array.
 */
@property(nonatomic, assign) BOOL isCustomPOICluster;

@end
