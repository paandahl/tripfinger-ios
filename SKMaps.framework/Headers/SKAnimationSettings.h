//
//  SKAnimationSettings.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKDefinitions.h"

/** Stores information about the annotation animation settings.
 */
@interface SKAnimationSettings : NSObject

/** Represents the animation type.
 */
@property(nonatomic, assign) SKAnimationType animationType;

/** Represents the animation easing type.
 */
@property(nonatomic, assign) SKAnimationEasingType animationEasingType;

/** The animation duration measured in milliseconds.
 */
@property(nonatomic, assign) int duration;

/** A newly initialized SKAnimationSettings. Default values SKAnimationPinDrop for animationType, SKAnimationEaseLinear for animationEasingType, 300 milliseconds for duration
 */
+ (instancetype)defaultAnimationSettings;

/** A newly initialized SKAnimationSettings. Default values SKAnimationNone for animationType, SKAnimationEaseLinear for animationEasingType, 0 for duration
 */
+ (instancetype)animationSettings;

@end
