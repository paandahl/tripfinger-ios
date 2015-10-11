//
//  SKMapView.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <UIKit/UIView.h>
#import "SKDefinitions.h"
#import "SKMapViewDelegate.h"
#import "SKMapSettings.h"

@class SKAnnotation;
@class SKMapCustomPOI;
@class SKBoundingBox;
@class SKCalloutView;
@class SKMapScaleView;
@class SKAnimationSettings;
@class SKCurrentPositionAnimationSettings;

/** The SKMapView class is used for displaying the map. It is the main class of the SKMaps framework and the entry point for all map related methods. SKMapView, like all UIKit objects, can only be managed from the main thread. Otherwise, it will result in an undefined behavior.
 */
@interface SKMapView : UIView

/** The delegate that must conform to SKMapViewDelegate protocol, used for observing user interactions changes in the map.
 */
@property(nonatomic, weak) id<SKMapViewDelegate> delegate;

#pragma mark - Settings

/** The SKMapSettings object that controls various UI and behavior settings of the map.
 */
@property(nonatomic, readonly, strong) SKMapSettings *settings;

/** All the annotations that are currently added to this map view.
 */
@property(nonatomic, readonly) NSArray *annotations;

/** The visible map coordinate region.
 */
@property(nonatomic, assign) SKCoordinateRegion visibleRegion;

/** Flag to verify if the map is in navigation mode or not.
 */
@property(nonatomic, readonly) BOOL isInNavigationMode;

/** Controls the maps bearing, in degrees. 0 = North, +90 = East, +180 = South, +270 = West. DPERECATED: Use the bearing property of SKMapSettings.
 */
@property(nonatomic, assign) float bearing;

#pragma mark - Built-In Subviews

/** Can be used for displaying data about a map POI or annotation. Can be activated using showCalloutAtLocation:withOffset: method. For further details check the SKCalloutView class.
 */
@property(nonatomic, strong) SKCalloutView *calloutView;

/** Manages the displaying of the map scale. The scale value is updated automatically based on the visible region of the map. By default it is hidden.
 */
@property(nonatomic, readonly) SKMapScaleView *mapScaleView;

/** Updates the current position icon on the map with a custom UIView. Setting the currentPositionView to nil restores the current position icon to it's default state.
 */
@property(nonatomic, strong) UIView *currentPositionView;

#pragma mark - Actions

/** Configures the map view with the map settings from the specified path.
 @param filePath The path to the configuration file.
 */
- (void)applySettingsFromFileAtPath:(NSString *)filePath;

/** Centers the map to the current position.
 */
- (void)centerOnCurrentPosition;

/** Animates the zooming of the map to a certain zoom level.
 @param zoom The zoom level the map will animate to.
 */
- (void)animateToZoomLevel:(float)zoom;

/** Animates the rotation of the map to a certain bearing.
 @param bearing The bearing to which the map will animate to, in degrees (in [ 0, 360 ] interval).
 */
- (void)animateToBearing:(float)bearing;

/** Animates the center of the map to a certain location.
 @param location The location to be centered.
 @param duration The duration of the animation, in seconds.
 */
- (void)animateToLocation:(CLLocationCoordinate2D)location withDuration:(float)duration;

/** Sets the visible region of the map so that a provided coordinate bounding box will be visible.
 @param boundingBox The bounding box to be fitted.
 @param padding Padding in pixels width (from left and right of the screen), height (from top and bottom of the screen)
 */
- (void)fitBounds:(SKBoundingBox *)boundingBox withPadding:(CGSize)padding;

#pragma mark - Conversions

/** Converts a CLLocationCoordinate2D location to a screen point of the current map view, if the location is in the current map region bounds.
 @param location The location to be converted.
 @return The converted CGPoint.
 */
- (CGPoint)pointForCoordinate:(CLLocationCoordinate2D)location;

/** Converts a CGPoint screen point to a CLLocationCoordinate2D location of the current map view.
 @param point The point to be converted.
 @return The converted location.
 */
- (CLLocationCoordinate2D)coordinateForPoint:(CGPoint)point;

#pragma mark - Annotations & Custom POIs

/** Adds an annotation to the map. By default, the center of the image will coincide with the location.
 @param annotation Model object for the annotation. For further details see SKAnnotation.
 @param animationSettings Represents the animation settings when adding an annotation to the map.
 */
- (BOOL)addAnnotation:(SKAnnotation *)annotation withAnimationSettings:(SKAnimationSettings *)animationSettings;

/** Adds a custom POI to the map.
 @param customPOI Model object of the custom POI. For further details see SKMapCustomPOI.
 */
- (BOOL)addCustomPOI:(SKMapCustomPOI *)customPOI;

/** Brings a previously added annotation in front of the others.
 @param annotation The the annotation to be brought in front.
 @return Success/failure of bringing the annotation in the front.
 */
- (BOOL)bringToFrontAnnotation:(SKAnnotation *)annotation;

/** Updates a previously added annotation on the map. The annotation will be updated with the new properties.
 @param annotation Annotation to be updated. For further details see SKAnnotation.
 @return Success/failure of updating the annotation.
 */
- (BOOL)updateAnnotation:(SKAnnotation *)annotation;

/** Returns an SKAnnotation object with the given identifier. If their is no annotation with the given identifier, it returns nil.
 @param identifier The annotation identifier.
 @return The annotation with the given identifier.
 */
- (SKAnnotation *)annotationForIdentifier:(int)identifier;

/** Removes the annotation with the specified ID.
 @param identifier The ID of the annotation to be deleted from the map.
 */
- (void)removeAnnotationWithID:(int)identifier;

/** Removes all markers from the map.
 */
- (void)clearAllAnnotations;

#pragma mark - Callout view

/** Displays the callout view at the provided coordinate.
 @param coordinate The coordinate where the callout view's arrow should point.
 @param calloutOffset Provides a way for moving the callout view up, down, left or right. It's recommended to use when the callout view covers a part of the annotation image.
 @param shouldAnimate A boolean value which indicated that the callout should appear animated at the given coordinate.
 */
- (void)showCalloutAtLocation:(CLLocationCoordinate2D)coordinate withOffset:(CGPoint)calloutOffset animated:(BOOL)shouldAnimate;

/** Displays the callout view at the provided coordinate.
 @param annotation The coordinate where the callout view's arrow should point.
 @param calloutOffset Provides a way for moving the callout view up, down, left or right. It's recommended to use when the callout view covers a part of the annotation image.
 @param shouldAnimate A boolean value which indicated that the callout should appear animated at the given coordinate.
 */
- (void)showCalloutForAnnotation:(SKAnnotation *)annotation withOffset:(CGPoint)calloutOffset animated:(BOOL)shouldAnimate;

/** Hides the callout view.
 */
- (void)hideCallout;

#pragma mark - Rendering

/** Generates a PNG image on the disk, with the map from the provided bounding box. This will be done asynchronously, and mapViewDidFinishRenderingImageInBoundingBox: will be called when the operation is finished.
 @param boundingBox The bounding box of the generated map.
 @param imagePath The path on the disk where the image should be generated.
 @param size The desired size of the image.
 */
- (void)renderMapImageInBoundingBox:(SKBoundingBox *)boundingBox toPath:(NSString *)imagePath withSize:(CGSize)size;

/** Returns a UIImage representation of the last rendered frame.
 */
-(UIImage*)lastRenderedFrame;

/** Starts an animation around the current position icon based on the given settings.
 @param currentPositionAnimationSettings The settings used for the pulse animation
 @return Success/failure
 */
- (BOOL)startCurrentPositionAnnimationWithSettings:(SKCurrentPositionAnimationSettings *)currentPositionAnimationSettings;

/** Stops the current position animation.
 @return Success/failure
 */
- (BOOL)stopCurrentPositionAnnimation;

@end