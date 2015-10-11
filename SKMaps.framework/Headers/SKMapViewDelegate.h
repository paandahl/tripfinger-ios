//
//  SKMapsDelegate.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKDefinitions.h"
#import <CoreGraphics/CGGeometry.h>
#import <UIKit/UIView.h>

@class SKAnnotation, SKMapPOI, SKTrafficIncident, SKMapView, SKMapCustomPOI, SKCalloutView, SKPOICluster;

/** The delegate of a SKMapView object must adopt the SKMapViewDelegate protocol. The SKMapViewDelegate protocol is used to receive map-related update messages.
 */
@protocol SKMapViewDelegate <NSObject>

@optional

/** Called when the region of the map will begin changing. During a panning/zooming gesture, this method is called once, at the beginning of the interaction.
 @param mapView The map view.
 @param region The current visible map region.
 */
- (void)mapView:(SKMapView *)mapView didStartRegionChangeFromRegion:(SKCoordinateRegion)region;

/** Called when the visible region of the map changes. During panning/zooming, this method may be called many times to report updates to the map visible region. The implementation of this method should be as lightweight as possible to avoid performance problems.
 @param mapView The map view.
 @param region The new visible map region.
 */
- (void)mapView:(SKMapView *)mapView didChangeToRegion:(SKCoordinateRegion)region;

/** Called when the region of the map will end changing. During a panning/zooming gesture, this method is called once, at the end of the interaction.
 @param mapView The map view.
 @param region The final visible map region.
 */
- (void)mapView:(SKMapView *)mapView didEndRegionChangeToRegion:(SKCoordinateRegion)region;

/** Called when the map is tapped.
 @param mapView The map view.
 @param coordinate The coordinate where the tap occured.
 */
- (void)mapView:(SKMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate;

/** Called when the map is long tapped.
 @param mapView The map view.
 @param coordinate The coordinate where the long tap occured.
 */
- (void)mapView:(SKMapView *)mapView didLongTapAtCoordinate:(CLLocationCoordinate2D)coordinate;

/** Called when the map is double tapped.
 @param mapView The map view.
 @param coordinate The coordinate where the double tap occured. On double tap, the map also zooms closer to that location.
 */
- (void)mapView:(SKMapView *)mapView didDoubleTapAtCoordinate:(CLLocationCoordinate2D)coordinate;

/** Called when the map is double touched.
 @param mapView The map view.
 @param point The centroid of the points where the double touch occured. On double touch, the map also zooms farther to that location.
 */
- (void)mapView:(SKMapView *)mapView didDoubleTouchAtPoint:(CGPoint)point;

/** Called when the map is panned.
 @param mapView The map view.
 @param fromPoint The point where the panning started.
 @param toPoint The point where the panning finished.
 */
- (void)mapView:(SKMapView *)mapView didPanFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint;

/** Called when the user pinched the SKMapView to zoom it.
 @param mapView The map view.
 @param scale The scale of the pinch. scale is > 1 for zoom in and < 1 for zoom out.
 */
- (void)mapView:(SKMapView *)mapView didPinchWithScale:(float)scale;

/** Called when the map is rotated.
 @param mapView The map view.
 @param angle The angle of the rotation, in degrees.
 */
- (void)mapView:(SKMapView *)mapView didRotateWithAngle:(float)angle;

/** Called when the map is panned to an area where no tiles are available and the framework is in connectivity mode offline.
 @param mapView The map view.
 */
- (void)mapViewWillRequireOnlineConnection:(SKMapView *)mapView;

/** Called when a map POI is tapped.
 @param mapView The map view.
 @param mapPOI The POI that was tapped.
 */
- (void)mapView:(SKMapView *)mapView didSelectMapPOI:(SKMapPOI *)mapPOI;

/** Called when an annotation was tapped on the map.
 @param mapView The map view.
 @param annotation The annotation that was tapped.
 */
- (void)mapView:(SKMapView *)mapView didSelectAnnotation:(SKAnnotation *)annotation;

/** Called when a custom POI was tapped on the map.
 @param mapView The map view.
 @param customPOI The custom POI that was tapped.
 */
- (void)mapView:(SKMapView *)mapView didSelectCustomPOI:(SKMapCustomPOI *)customPOI;

/**An annotations cluster was tapped. Use this method to provide extra info for selected annotations cluster.
 @param poiCluster Stores information about the selected annotation cluster. For durther details see the SKPOICluster class.
 @param mapView The map view.
 */
- (void)mapView:(SKMapView *)mapView didSelectPOICluster:(SKPOICluster *)poiCluster;

/** Called when the compass of the map view was tapped.
 @param mapView The map view.
 */
- (void)mapViewDidSelectCompass:(SKMapView *)mapView;

/** Called when the curent position icon on the map view was tapped.
 @param mapView The map view.
 */
- (void)mapViewDidSelectCurrentPositionIcon:(SKMapView *)mapView;

/** Called when a callout should be shown at a certain position.(After calling the showCalloutAtLocation:withOffset:animated: method this method will be called immediately)
 @param mapView The map view.
 @param location The location of the callout view.
 */
- (UIView *)mapView:(SKMapView *)mapView calloutViewForLocation:(CLLocationCoordinate2D)location;

/** Called when a callout should be shown for a certain annotation.(After calling the showCalloutForAnnotation:withOffset:animated: method this method will be called immediately)
 @param mapView The map view.
 @param annotation The annotation of the callout view.
 */
- (UIView *)mapView:(SKMapView *)mapView calloutViewForAnnotation:(SKAnnotation *)annotation;

/** Called when one of the attributions is tapped.
 @param mapView The map view.
 */
- (void)mapViewDidTapAttribution:(SKMapView *)mapView;

/** Called when one of the overlays is tapped.
 @param mapView The map view.
 @param overlayId The identifier of the overlay.
 @param location The location where the tap occured.
 */
- (void)mapView:(SKMapView *)mapView didSelectOverlayWithId:(int)overlayId atLocation:(CLLocationCoordinate2D)location;

/** Called when the asynchronous rendering of a map image in a file did finish.
 @param mapView The map view.
 */
- (void)mapViewDidFinishRenderingImageInBoundingBox:(SKMapView *)mapView;


@end
