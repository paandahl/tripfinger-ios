//
//  SKMapView+RealReach.h
//  SKMaps
//
//  Copyright (c) 2014 Skobbler. All rights reserved.
//

#import "SKMapView.h"
#import <CoreLocation/CoreLocation.h>

@class SKRealReachSettings;

/**
 */
@interface SKMapView (RealReach)

/** Adds a RealReach layer on the map.
 @param realReachSettings Contains settings for the RealReach layer.
 */
- (void)displayRealReachWithSettings:(SKRealReachSettings *)realReachSettings;

/** Clears the RealReach layer from the map.
 */
- (void)clearRealReachDisplay;

/** Verifies is the RealReach layer fits in the specified bounding box.
 @param boundingBox Defines a bounding box on the map.
 @return A boolean value indicating if the RealReach fits in the specified bounding box.
 */
- (BOOL)isRealReachDisplayedInBoundingBox:(SKBoundingBox *)boundingBox;

/** Verifies is a coordinate is inside the RealReach polygon.
 @param coordinate The coordinate to be checked.
 @return A boolean value indicating if the coordinate is inside the rendered RealReach polygon.
 */
-(BOOL)isCoordinateInsideRealReachPolygon:(CLLocationCoordinate2D)coordinate;

@end
