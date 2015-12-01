//
//  SKPolygon.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import <UIKit/UIColor.h>
#import "SKOverlay.h"

/** SKPolygon stores the information related to a map polygon overlay. This object is used as an input parameter.
 */
@interface SKPolygon : SKOverlay

/** An array of CLLocation objects. Each location represents a vertex of the polygon. The first and the last vertices will be linked.
 */
@property(nonatomic, strong) NSArray *coordinates;

/** The width of the border. Should be a value in [ 1, 10 ] interval.
 */
@property(nonatomic, assign) int borderWidth;

/** If YES, the outer area will be colored according to the rest of the settings.
 */
@property(nonatomic, assign) BOOL isMask;

/** Scale of the outer mask. Multiplies the radius value of the circle. If set to 0, the entire map will be colored.
 */
@property(nonatomic, assign) float maskedObjectScale;

/** A newly initialized SKPolygon.
 */
+ (instancetype)polygon;

@end
