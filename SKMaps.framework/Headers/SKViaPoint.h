//
//  SKViaPoint.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

/** The SKViaPoint is used to store information about a viapoint used for route calculation.
 */
@interface SKViaPoint : NSObject

/** The unique identifier of the viapoint.
 */
@property(nonatomic, assign) int identifier;

/** The location of the viapoint.
 */
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;

/** A newly initialized default SKViaPoint object.
 */
+ (instancetype)viaPoint;

/** A newly initialized SKViaPoint object.
 @param viaPointID The unique identifier of the viapoint.
 @param viaPointCoordinate The location of the viapoint.
 */
+ (instancetype)viaPoint:(int)viaPointID withCoordinate:(CLLocationCoordinate2D)viaPointCoordinate;

@end
