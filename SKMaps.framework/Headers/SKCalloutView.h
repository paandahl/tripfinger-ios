//
//  SKCalloutView.h
//  ForeverMapNGX
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CLLocation.h>
#import "SKCalloutViewDelegate.h"

@class SKAnnotation;

/** SKMapView's callout view. Can be used to display additional information about map artefacts. Responsible for displaying information about a map POI/annotation. Using the following properties the callout view's visual presentation on map can be configured.
 */
@interface SKCalloutView : UIView

/** The delegate of the callout view, used for receiving user interaction notifications from the callout view.
 */
@property(nonatomic, assign) id<SKCalloutViewDelegate> delegate;

/** The GPS coordinate where the callout view's arrow should point.
 */
@property(nonatomic, assign) CLLocationCoordinate2D location;

/** Provides a way for moving the callout view up, down, left or right. It's recommended to use when the callout view covers a part of the annotation image.
 */
@property(nonatomic, assign) CGPoint calloutOffset;

/** Enables the callout view's arrow dynamic positioning while interacting with the map (panning, zooming).
 */
@property(nonatomic, assign) BOOL dynamicArrowPositioning;

/** The image view which contains the image of the arrow.
 */
@property(nonatomic, strong) UIImageView *middleImageView;

/** The button located on the callout view's left side. It can be customized like any other UIButton. Any interaction with this button will be forwarded to the callout view's delegate (see SKCalloutViewDelegate).
 */
@property(nonatomic, strong) UIButton *leftButton;

/** The button located on the callout view's right side. It can be customized like any other UIButton. Any interaction with this button will be forwarded to the callout view's delegate(see SKCalloutViewDelegate).
 */
@property(nonatomic, strong) UIButton *rightButton;

/** The title label of the callout view.
 */
@property(nonatomic, strong) UILabel *titleLabel;

/** The subtitle label of the callout view.
 */
@property(nonatomic, strong) UILabel *subtitleLabel;

/** The minimum zoom level on which the callout view will be visible.
 */
@property(nonatomic, assign) CGFloat minZoomLevel;

/**A newly initialized SKCalloutView.
 */
+ (instancetype)calloutView;

@end
