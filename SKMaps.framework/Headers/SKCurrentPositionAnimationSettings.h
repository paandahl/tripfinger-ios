//
//  SKCurrentPositionAnimationSettings.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKAnimationSettings.h"
@class UIColor;

/** Stores the settings for a current position animation.
 */
@interface SKCurrentPositionAnimationSettings : SKAnimationSettings

/** The color of the animation.
 */
@property(nonatomic, strong) UIColor *color;

/** Specifies if the animation is continuous.
 */
@property(nonatomic, assign, getter = isContinuous) BOOL continuous;

/** The span of the animation. The size of the animation by multiplying it by the current position image size. For example if span value is set to 3.0, the animation size will be three times bigger than the current position image size. Default value is 2.0.
 */
@property(nonatomic, assign) float span;

/** The time needed for the animation to dissapear, measured in milliseconds.
 */
@property(nonatomic, assign) int fadeOutTime;

/** A newly initialized SKCurrentPositionAnimationSettings.
 */
+ (instancetype)currentPositionAnimationSettings;

@end
