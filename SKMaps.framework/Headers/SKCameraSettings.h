//
//  SK3DCameraSettings.h
//  SKMaps
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/** Contains settings that control how the map is viewed.
 */

@interface SKCameraSettings : NSObject

/**
 Controls the rotation point of the camera. Valid values are from [ 0.1, 0.9 ] interval. Default is 0.3.
 */
@property (nonatomic, assign) CGFloat center;

 /**
  Controls the camera tilt. Valid values are from [ 0,  90 ] interval. Default is 15.
 */
@property (nonatomic, assign) CGFloat tilt;

/**
 Controls the distance of the camera from the center of the map. Valid values are from [ 30, 300 ] interval. Default is 144.
 */
@property (nonatomic, assign) CGFloat distance;

/**
 New instance of SK3DCameraSettings with default values.
 */
+ (SKCameraSettings *)cameraSettings;

/**
 New instance of SK3DCameraSettings with desired values.
 @param center Center of the camera.
 @param tilt Tilt of the camera.
 @param distance Distance of the camera.
 */
+ (SKCameraSettings *)cameraSettingsWithCenter:(CGFloat)center tilt:(CGFloat)tilt distance:(CGFloat)distance;

@end
