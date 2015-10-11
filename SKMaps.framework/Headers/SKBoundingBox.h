//
//  SKBoundingBox.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKDefinitions.h"
#import <CoreLocation/CLLocation.h>
#import <UIKit/UIView.h>

/** The SKBoundingBox is used to define a bounding box on the map between a bottom right and top left coordinates.
 */

@interface SKBoundingBox : NSObject

/** The top left coordinate of the bounding box.
 */
@property(nonatomic, assign) CLLocationCoordinate2D topLeftCoordinate;

/** The bottom right coordinate of the bounding box.
 */
@property(nonatomic, assign) CLLocationCoordinate2D bottomRightCoordinate;

/** Verifies if a given location is within a bounding box.
 @param location The location.
 @return The result of the verification(YES if the location is within the bounding box, No otherwise).
 */
- (BOOL)containsLocation:(CLLocationCoordinate2D)location;

/** Returns a newly created bounding box with the given location inside the receiver bounding box.
 @param location The location.
 @return The newly created bounding box object. If the location is already inside the bounding box then the receiver bounding box will be returned.
 */
- (SKBoundingBox *)boundingBoxIncludingLocation:(CLLocationCoordinate2D)location;

/** A newly initialized SKBoundingBox.
 @param topLeft The top left coordinate for the bounding box.
 @param bottomRight The bottom right coordinate for the bounding box.
 */
+ (instancetype)boundingBoxWithTopLeftCoordinate:(CLLocationCoordinate2D)topLeft bottomRightCoordinate:(CLLocationCoordinate2D)bottomRight;

/** A newly initialized SKBoundingBox.
 @param region The map region to be converted.
 @param size The size of the SKMapView's frame.
 */
+ (instancetype)boundingBoxForRegion:(SKCoordinateRegion)region inMapViewWithSize:(CGSize)size;
@end
