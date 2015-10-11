//
//  SKDetectedPOI.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKDefinitions.h"

/** SKDetectedPOI stores information about a detected POI by the SKPOITracker.
 */
@interface SKDetectedPOI : NSObject

/** The unique identifier of the signaled POI.
 */
@property(nonatomic, assign) int poiID;

/** The route distance to the signaled POI, in meters.
 */
@property(nonatomic, assign) int distance;

/** The type of the detected POI.
 */
@property(nonatomic, assign) SKTrackablePOIType type;

/** The reference distance to the signaled POI, in meters.
 */
@property(nonatomic, assign) int referenceDistance;

/** A newly initialized SKDetectedPOI.
 */
+ (instancetype)detectedPOI;

@end
