//
//  SKCrossingDescriptor.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Contains information about how to generate visual advice images.
 */
@interface SKCrossingDescriptor : NSObject

/** The type of the crossing.
 */
@property(nonatomic, assign) int crossingType;

/** The angle of the route.
 */
@property(nonatomic, assign) float routeAngle;

/** If it's YES then the crossing will turn to right
 */
@property(nonatomic, assign) BOOL turnToRight;

/** The direction of the crossing
 */
@property(nonatomic, assign) BOOL directionUK;

/** The angles of the allowed routes.
 */
@property(nonatomic, strong) NSMutableArray *allowedRoutesAngles;

/** The angles of the forbidden routes.
 */
@property(nonatomic, strong) NSMutableArray *forbiddenRoutesAngles;

@end
