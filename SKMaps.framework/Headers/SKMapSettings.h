//
//  SKMapSetting.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>
#import "SKDefinitions.h"

@class SKMapInternationalizationSettings, SKTrailSettings, SKCameraSettings;

/** SKMapSettings stores and controls various UI and behavior settings for the SKMapView class. This class should not be instantiated by the client application.
 */
@interface SKMapSettings : NSObject

#pragma mark - Gestures

/** Controls if rotation gestures are enabled or disabled. Default value is YES.
 */
@property(nonatomic, assign) BOOL rotationEnabled;

/** Controls if panning gestures are enabled or disabled. Default value is YES.
 */
@property(nonatomic, assign) BOOL panningEnabled;

/** If set to YES, when pinched the map will always zoom to the center point of the map instead of the pinched points. Default is NO.
 */
@property(nonatomic, assign) BOOL zoomWithCenterAnchor;

/** Controls map inertia for panning/zooming/rotating gestures. Default value is YES.
 */
@property(nonatomic, assign) BOOL inertiaEnabled;

#pragma mark - Settings

/** Controls if the compass indicating the map bearing is displayed. Default value is NO.
 */
@property(nonatomic, assign) BOOL showCompass;

/** Controls if the accuracy circle is displayed. Default value is YES.
 */
@property(nonatomic, assign) BOOL showAccuracyCircle;

/** The relative position of the compass compared to its initial position (top right corner). For moving the compass to the left, set positive value to x, to move down set positive value to y. Default value is (0,0).
 */
@property(nonatomic, assign) CGPoint compassOffset;

/** Allows or stops the map rendering when the map is visible. Default value is YES. When the map is not visible, rendering is automatically stopped.
 */
@property(nonatomic, assign) BOOL enabledRendering;

/** Manages the displaying of debug information, like the center coordinate of the map and the zoom level. By default is set to NO.
 */
@property(nonatomic, assign) BOOL showDebugView;

/** The orientation indicator type, used when SKMapFollowerModePositionPlusHeading follower is active. If SKOrientationIndicatorCustomImage is set, the "heading.png" image file from the style's resources will be used.
 */
@property(nonatomic, assign) SKOrientationIndicatorType orientationIndicatorType;

/** Controls the map display mode ( 2D / 3D ).
 */
@property(nonatomic, assign) SKMapDisplayMode displayMode;

/** Controls how the map is viewed while in 3D mode. Changing the properties of cameraSettings directly does not have any effect. You must configure your SK3DCameraSettings object then assign it to this property.
 */
@property(nonatomic, strong) SKCameraSettings *cameraSettings;

/** A mask of SKPOIDisplayingOption elements used to configure map POIs displaying. By default all of the POIs are displayed.
 */
@property(nonatomic, assign) SKPOIDisplayingOption poiDisplayingOption;

/** Controls the maps labeling language and transliteration. For further details see SKMapInternationalizationSettings.
 */
@property(nonatomic, strong) SKMapInternationalizationSettings *mapInternationalization;

/** Used for setting the zoom limits of the map. For the minimum and maximum values, check the SKDefinitions constants.
 */
@property(nonatomic, assign) SKMapZoomLimits zoomLimits;

/** Defines the starting zoom level where the annotation selection works. By default it's 12.0.
 */
@property(nonatomic,assign) float annotationTapZoomLimit;

/** Marks the path behind the current position with trail settings.
 */
@property(nonatomic, strong) SKTrailSettings *trailSettings;

#pragma mark - Display

/** Controls if the current position icon is displayed on the map.
 */
@property(nonatomic, assign) BOOL showCurrentPosition;

/** Controls if the street names should be displayed as pop-ups in 3D mode. Default value is NO.
 */
@property(nonatomic, assign) BOOL showStreetNamePopUps;

/** Controls if bicycle lanes are rendered on the map. Default value is NO.
 */
@property(nonatomic, assign) BOOL showBicycleLanes;

/** Controls if house numbers are rendered on the map. Default value is YES.
 */
@property(nonatomic, assign) BOOL showHouseNumbers;

/** Controls if one way streets are rendered on the map. Default value is YES.
 */
@property(nonatomic, assign) BOOL showOneWays;

/** Controls if street badges are rendered on the map. Default value is YES.
 */
@property(nonatomic, assign) BOOL showStreetBadges;

/** Controls the framerate of the map for non user interaction camera changes ( navigation, inertia, etc. ). Default is 30 fps.
 */
@property(nonatomic, assign) NSInteger frameRate;

#pragma mark - Logo

/** Indicates the position of the osm attribution.
 */
@property(nonatomic, assign) SKAttributionPosition osmAttributionPosition;

/** Indicates the position of the company attribution.
 */
@property(nonatomic, assign) SKAttributionPosition companyAttributionPosition;

/** Specifies the drawing order for the drawable objects (e.g. polygons, polylines) and annotations. By default the annotations are rendered over drawable objects
 */
@property(nonatomic, assign) SKDrawingOrderType drawingOrderType;

/** Controls if the map follows the user position. The default value is NO.
 */
@property(nonatomic, assign) BOOL followUserPosition;

/** Controls the heading mode of the map. The default value is SKHeadingModeNone.
 */
@property(nonatomic, assign) SKHeadingMode headingMode;

/** BETA: Controls if the map is transparent or opaque. Default is NO.
 */
@property(nonatomic, assign) BOOL transparencyEnabled;

#pragma mark - Deprecated

/** Controls if the map POI icons are rendered on the map. Default value is YES. DEPRECATED: Use the poiDisplayingOption property for configuring the appearence of map POIs. For hiding all the POIs set the poiDisplayingOption property to SKPOIDisplayingOptionNone. For displaying all the POIs set the poiDisplayingOption property to SKPOIDisplayingOptionCity | SKPOIDisplayingOptionGeneral | SKPOIDisplayingOptionImportant.
 */
@property(nonatomic, assign) BOOL showMapPoiIcons DEPRECATED_ATTRIBUTE;


#pragma mark - Factory method

/** A newly initialized SKMapSettings.
 */
+ (instancetype)mapSettings;

@end
