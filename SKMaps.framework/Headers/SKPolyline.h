//
//  SKPolyline.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import <UIKit/UIColor.h>
#import "SKOverlay.h"

/** SKPolyline stores the information related to a map plyline overlay. This object is used as an input parameter.
 */
@interface SKPolyline : SKOverlay

/** An array of CLLocation objects. Each location represents a vertex of the polyline.
 */
@property(nonatomic, strong) NSArray *coordinates;

/** The width of the polyline. Should be a value in [ 1, 10 ] interval.
 */
@property(nonatomic, assign) int lineWidth;

/** The width of the backgrund line. Should be a value in [ 1, 10 ] interval.
 */
@property(nonatomic, assign) int backgroundLineWidth;

/** A newly initialized SKPolyline.
 */
+ (instancetype)polyline;

@end
