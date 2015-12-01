//
//  SKRoutingService.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKRoutingDelegate.h"
#import "SKNavigationDelegate.h"

@class SKMapView;
@class SKRouteSettings;
@class SKNavigationSettings;
@class SKAdvisorSettings;
@class SKViaPoint;
@class SKVisualAdviceConfiguration;

/** SKRoutingService provides services for calculating routes and navigation.
 */
@interface SKRoutingService : NSObject

/** The delegate that must conform to SKRoutingDelegate protocol, used  for receiving route calculation callbacks.
 */
@property(nonatomic, weak) id<SKRoutingDelegate> routingDelegate;

/** The delegate that must conform to SKNavigationDelegate protocol, used for receiving navigation callbacks.
 */
@property(nonatomic, weak) id<SKNavigationDelegate> navigationDelegate;

/** The map view where the calculated routes and the navigation will be displayed.
 */
@property(nonatomic, weak) SKMapView *mapView;

/** The unique identifier of the main route. Main route will be used if a turn by turn navigation is started and will be rendered differently than alternatives.
 */
@property(nonatomic, assign) SKRouteID mainRouteId;

/** Manages the audio advisor configuration settings.
 */
@property(nonatomic, strong) SKAdvisorSettings *advisorConfigurationSettings;

/** An array of SKVisualAdviceConfiguration objects used for configuring the color of the advisor images in different countries and streets.
 */
@property(nonatomic, strong) NSArray *visualAdviceConfigurations;

/** Returns the singleton SKRoutingService instance.
 */
+ (instancetype)sharedInstance;

/** Starts route calculations. The routingDelegate will receive calculation status notifications.
 @param route Stores route calculation settings.
 */
- (void)calculateRoute:(SKRouteSettings *)route;

/** Zooms the map to the current calculated route.
 @param insets Contains information about the zooming insets for the route overview.
 @param duration The duration of the animation in miliseconds. No animation will be performed if the value of this parameter is 0.
 */
- (void)zoomToRouteWithInsets:(UIEdgeInsets)insets duration:(int)duration;

/** Clears the current routes, including alternatives.
 */
- (void)clearCurrentRoutes;

/** Clears the route alternatives, keeping the main one.
 */
- (void)clearRouteAlternatives;

/** Returns the array of coordinates for the current route. In order for 'elevation' property of returned results to be accurate, requestExtendedRoutePointsInfo of the SKRouteSettings must be set to YES.
 @param routeId The identifier of the route which can be obtained from the returned SKRouteInformation.
 @return The array of route coordinates ( CLLocation objects ), including altitude, if available.
 */
- (NSArray *)routeCoordinatesForRouteWithId:(int)routeId;

/** Returns the array of country codes that the route crosses. In order for this to work, requestCountryCodes of the SKRouteSettings must be set to YES.
 @param routeId The identifier of the route which can be obtained from the returned SKRouteInformation.
 @return The array of country codes that the route crosses ( NSString objects ).
 */
- (NSArray *)routeCountriesForRouteWithId:(int)routeId;

/** Returns the array of advices for the current route. In order for this to work, requestAdvices of the SKRouteSettings must be set to YES.
 @param distanceFormat The measurment unit of the distance. By default is set SKDistanceFormatMetric.
 @return The array of advices ( SKRouteAdvice objects ).
 */
- (NSArray *)routeAdviceListWithDistanceFormat:(SKDistanceFormat)distanceFormat;

/** Generates and returns an image about the visual advice using the given configuration.
 @param routeAdvice Contains all the information about an advice.
 @param visualAdviceColor The SKVisualAdviceConfiguration is used to store the colors of a generated visual advice image.
 @return An image about the advice.
 */
- (UIImage *)visualAdviceImageForRouteAdvice:(SKRouteAdvice *)routeAdvice color:(SKVisualAdviceConfiguration *)visualAdviceColor;

/** Converts the main component of a GPX file into a route.
 @param path The path to the GPX file.
 */
- (void)startRouteFromGPXFile:(NSString *)path;

#pragma mark - Navigation

/** Starts the navigation. If a route is already calculated, it will be used for turn by turn navigation, otherwise a free drive session will begin.
 In order to receive navigation updates, use the navigationDelegate.
 @param navigationSettings The settings of the navigation. For more info, visit the SKNavigationSettings documentation. If nil, default settings will be used.
 @return Success/failure of starting the navigation.
 */
- (BOOL)startNavigationWithSettings:(SKNavigationSettings *)navigationSettings;

/** Stops the current navigation session.
 */
- (void)stopNavigation;

/** Signals that the road ahead is blocked at a given distance. Blocking the road will trigger a rerouting, in navigation mode and the recalculation of the current route, in map mode.
 @param distance Distance to the block from the current position or from the start point, in meters.
 */
- (void)blockRoads:(double)distance;

/** Signals that the road ahead has been unblocked. In navigation mode unblocks all previously blocked roads and causes a rerouting. In map mode unblocks all previously blocked roads and relaunches the calculation of the current route.
 */
- (void)unBlockAllRoads;

/** Adds a viapoint to an already existing route. After using calculateRoute, further viapoints can be added to the route (viaPoints array from SKRouteSettings contains the predefined route viapoint). Adding a viapoint in navigation mode triggers a re-routing, in map mode triggers the re-calculation of the current route.
 @param viaPoint Stores the information about the viapoint.
 @param viaPointID Identifies the via point after which the new via point is inserted. -1 should be used to insert the new viapoint to the beginning of the viapoint list.
 */
- (void)addViaPoint:(SKViaPoint *)viaPoint afterViaPointWithID:(int)viaPointID;

/** Removes the viapoint (identified with viaPointID). After using calculateRoute, predefined viapoints can be removed from the route (viaPoints array from SKRouteSettings contains the predefined route viapoint). Removing a viapoint in navigation mode triggers a re-routing, in map mode triggers the re-calculation of the current route.
 @param viaPointID Identifies the via point.
 */
- (void)removeViaPoint:(int)viaPointID;

/** When called, the current speed limit audio info will be provided, in navigationDelegate's routingService:didUpdateSpeedWarningToStatus:withAudioWarnings:insideCity: callback.
 */
- (void)giveNowSpeedLimitAudioInfo;

/** Modifies the configurations of a navigation.
  @param navigationSettings stores settings for a navigation session.
 */
- (void)changeNavigationSettings:(SKNavigationSettings *)navigationSettings;

#pragma mark - Route caching

/** Saves the route with a given identifier to the cache. Later this route can be reused without the need to recalculate it. Closing the app will delete the route from the cache, so in the next app start it can't be reused.
 @param routeId The identifier of the route from the returned SKRouteInformation.
 @return Success/Failure of caching a route.
 */
- (BOOL)saveRouteToCache:(SKRouteID)routeId;

/** Removes the route with a given identifier from the cache.
 @param routeId The identifier of the route.
 */
- (void)removeRouteFromCache:(SKRouteID)routeId;

/** Removes all the cached routes.
 */
- (void)clearAllRoutesFromCache;

/** Loads the route with a given identifier from the cache, without recalculating it.
 @param routeId The identifier of the route.
 */
- (void)loadRouteFromCache:(SKRouteID)routeId;


@end
