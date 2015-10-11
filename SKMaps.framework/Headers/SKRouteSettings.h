//
//  SKRouteSettings.h
//  SKMaps
//
//  Copyright (c) 2013 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "SKDefinitions.h"

/** The SKRouteSettings stores settings about a route. Used as input for a route calculation.
 */
@interface SKRouteSettings : NSObject

/** The start coordinate of the route.
 */
@property(nonatomic, assign) CLLocationCoordinate2D startCoordinate;

/** The destination coordinate of the route.
 */
@property(nonatomic, assign) CLLocationCoordinate2D destinationCoordinate;

/** Via Points along the route. An array of SKViaPoint objects.
 */
@property(nonatomic, strong) NSArray *viaPoints;

/** The route calculation mode. The default is SKRouteCarEfficient.
 */
@property(nonatomic, assign) SKRouteMode routeMode;

/** The route calculation connectivity mode. The default value is SKRouteConnectionHybrid.
 */
@property(nonatomic, assign) SKRouteConnectionMode routeConnectionMode;

/** Indicates whether the route should be rendered on the map.
 */
@property(nonatomic, assign) BOOL shouldBeRendered;

/** Indicates whether to avoid toll roads, highways (Motorways & Motorway links), ferry lines, roads that make the user walk along his bike or carry his bike when calculating the route.
 */
@property(nonatomic, assign) SKRouteRestrictions routeRestrictions;

/** If set to YES, routeCountriesForRouteWithId: will return valid country codes after calculation. Default is NO.
 */
@property(nonatomic, assign) BOOL requestCountryCodes;

/** If set to YES, the route can be used for turn by turn navigation and getRouteAdviceList will return valid advices. Default is YES.
 */
@property(nonatomic, assign) BOOL requestAdvices;

#pragma mark - Route Alternatives

/** The maximum number of routes returned by the SDK. Default value is 1. In some cases you would like to calculate more routes then the number specified by this property and to get the best routes limited by this number. For configuring the desired alternative routes please see the documentation of the SKRouteAlternativeSettings class.
 */
@property(nonatomic, assign) NSUInteger maximumReturnedRoutes;

/** Route calculation modes for alternative routes, an array of SKRouteAlternativeSettings objects. If nil, default alternatives will be generated.
 */
@property(nonatomic, strong) NSArray *alternativeRouteCalculations;


#pragma mark - Advanced settings

/** Indicates whether to use the roads' slopes when calculating the route.
 */
@property(nonatomic, assign) BOOL useSlopes;

/** If set to YES, routeCoordinatesForRouteWithId: coordinates will also contain elevation data. Will be slower to calculate. Default is NO.
 */
@property(nonatomic, assign) BOOL requestExtendedRoutePointsInfo;

/** Indicates whether to download the tiles of the route corridor.
 */
@property(nonatomic, assign) BOOL downloadRouteCorridor;

/** It specifies the route corridor width, in meters. The corridor will have routeCorridorWidth on both sides of the route.
 */
@property(nonatomic, assign) int routeCorridorWidth;

/** Indicates whether to wait for the corridor download before sending the route calculation finished callback.
 */
@property(nonatomic, assign) BOOL waitForCorridorDownload;

/** Indicates whether the destination is a specific point ( POI, street with house number, etc. ) or not ( a street, a city ).
 This affects audio advices for reaching the destination.
 */
@property(nonatomic, assign) BOOL destinationIsPoint;

#pragma mark - Factory method

/** A newly initialized SKRouteSettings.
 */
+ (instancetype)routeSettings;

#pragma mark - Deprecated

/** Indicates whether to filter/remove the alternatives that are too similar with the previous calculated ones. Two routes are considered similar if less than 10% of them are different. DEPRECATED: For configuring the route calculation mode of the alternative routes please see the documentation of the SKRouteAlternativeSettings class.
 */
@property(nonatomic, assign) BOOL filterAlternatives DEPRECATED_ATTRIBUTE;

/** The number of routes to be calculated, including alternatives. Setting this property to a value > 1 is enough for getting basic route alternatives. Default value is 1. DEPRECATED: Use maximumReturnedRoutes.
 */
@property(nonatomic, assign) NSUInteger numberOfRoutes DEPRECATED_ATTRIBUTE;

/** Route calculation modes for alternative routes, an array of SKRouteAlternativeSettings objects. If nil, default alternatives will be generated. DEPRECATED: Use alternativeRouteCalculations.
 */
@property(nonatomic, strong) NSArray *alternativeRoutesModes DEPRECATED_ATTRIBUTE;


@end
