//
//  SKCalloutViewDelegate.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SKCalloutView;

/**The SKCalloutViewDelegate defines a set of optional methods that you can use to receive notifications when the user interacts with the SKMapView's callout view.
 */
@protocol SKCalloutViewDelegate <NSObject>

@optional

/** Called when the user taps on the left button.
 @param calloutView The callout view.
 @param leftButton  The left button.
 */
- (void)calloutView:(SKCalloutView *)calloutView didTapLeftButton:(UIButton *)leftButton;

/** Called when the user taps on the right button.
 @param calloutView The callout view.
 @param rightButton  The right button.
 */
- (void)calloutView:(SKCalloutView *)calloutView didTapRightButton:(UIButton *)rightButton;

@end
