//
//  SKZoomLevelConfiguration.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKDefinitions.h"

/** SKZoomLevelConfiguration stores information about the speed interval for a zoom level that will be used during navigation.
 */
@interface SKZoomLevelConfiguration : NSObject

/** The speed interval for a zoom level. The minimumSpeed and maximumSpeed members of the speedInterval property must be  provided in km/h.
 */
@property (nonatomic, assign) SKSpeedInterval speedInterval;

/** The zoom level for the defined speed interval. The value of this property must be between 0.0 and 19.0 .
 */
@property (nonatomic, assign) float zoomLevel;

/** A newly initialized SKZoomLevelConfiguration.
 */
+ (instancetype)zoomLevelConfiguration;

@end
