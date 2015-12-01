//
//  SKCircle.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import <UIKit/UIColor.h>
#import "SKOverlay.h"

/** SKCircle stores the information related to a circle map overlay. This object is used as an input parameter.
 */
@interface SKCircle : SKOverlay

/** The center coordinate of the circle.
 */
@property(nonatomic, assign) CLLocationCoordinate2D centerCoordinate;

/** The radius of the circle in meters.
 */
@property(nonatomic, assign) float radius;

/** The width of the border. Should be a value in [ 1, 10 ] interval.
 */
@property(nonatomic, assign) int borderWidth;

/** If YES, the outer area will be colored according to the rest of the settings.
 */
@property(nonatomic, assign) BOOL isMask;

/** Scale of the outer mask. Multiplies the radius value of the circle. If set to 0, the entire map will be colored.
 */
@property(nonatomic, assign) float maskedObjectScale;

/** The number of points to represent the border of the circle (is bounded in the [ 36, 180 ] interval).
 */
@property(nonatomic, assign) int numberOfPoints;

/** A newly initialized SKCircle.
 */
+ (instancetype)circle;

@end
