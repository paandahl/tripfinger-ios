//
//  SKMapScaleView.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKDefinitions.h"

/** SKMapView's scale view. Can be enabled to display the ratio of a distance on a map to the corresponding distance on the ground.
 */
@interface SKMapScaleView : UIView

/** The scale value in meters per pixel.
 */
@property(nonatomic, assign) CGFloat scale;

/** The measurement unit to be used when displaying the scale value. Default is SKDistanceFormatMetric.
 */
@property(nonatomic, assign) SKDistanceFormat distanceFormat;

/** Enables night style color scheme.
 */
@property (nonatomic, assign) BOOL nightStyle;

@end
