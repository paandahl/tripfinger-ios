//
//  SKCoordinate.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>

/** SKCoordinate is used to store information about a GPS coordinate.
 */
@interface SKCoordinate : NSObject

/** The latitude of the coordinate point.
 */
@property(nonatomic, assign) double latitude;

/** The longitude of the coordinate point.
 */
@property(nonatomic, assign) double longitude;

/** The altitude of the coordinate point.
 */
@property(nonatomic, assign) double altitude;

/** The name of the coordinate point.
 */
@property(nonatomic, strong) NSString *name;

/** The description of the coordinate point.
 */
@property(nonatomic, strong) NSString *description;

/** The timestamp of the coordinate point.
 */
@property(nonatomic, strong) NSDate *time;

/** A newly initialized SKCoordinate.
 */
+ (instancetype)coordinate;

@end
