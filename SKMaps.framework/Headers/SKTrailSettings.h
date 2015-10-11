//
//  SKTrailSettings.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>

/** SKTrailSettings stores settings for trail UI during turn by turn navigation.
 */
@interface SKTrailSettings : NSObject

/** Dotted trail or line.
 */
@property(nonatomic, assign, getter = isDotted) BOOL dotted;

/** Trail's color.
 */
@property(nonatomic, strong) UIColor *color;

/**Trail's width. Must be in (1-10) interval.
 */
@property(nonatomic, assign) unsigned int width;

/**Sets the trail to pedestrian. The default value is NO.
 */
@property(nonatomic, assign) BOOL enablePedestrianTrail;

/**Specifies the smooth level for the pedestrian trail. The default value is 1.
 */
@property(nonatomic, assign) int pedestrianTrailSmoothLevel;

/** A newly initialized SKTrailSettings.
 */
+ (instancetype)trailSettings;

@end
