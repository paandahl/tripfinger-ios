//
//  SKRouteInformation.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKDefinitions.h"

/** SKRouteInformation stores information returned on a route calculation. An instance of this class is returned as parameter in the routingService:didFinishRouteCalculationWithInfo: callback when a new route is calculated. The routeID property of an SKRouteInformation instance is used in several SKRoutingService methods as parameter for returning different kind of information about a calculated route. ( e.g. routeCoordinatesForRouteWithId:, routeCountriesForRouteWithId:)
 */
@interface SKRouteInformation : NSObject

/** The unique identifier of the calculated route.
 */
@property(nonatomic, assign) SKRouteID routeID;

/** The route calculation mode.
 */
@property(nonatomic, assign) SKRouteMode routeMode;

/** The distance of the calculated route, in meters.
 */
@property(nonatomic, assign) int distance;

/** The estimated duration of the calculated route, in seconds.
 */
@property(nonatomic, assign) int estimatedTime;

/** Flag that indicates if the route corridor was downloaded.
 */
@property(nonatomic, assign) BOOL corridorIsDownloaded;

/** Flag that indicates if the route was calculated due to a rerouting.
 */
@property(nonatomic, assign) BOOL calculatedAfterRerouting;

/** Flag that indicates if the rute contains highways.
 */
@property(nonatomic, assign) BOOL containsHighways;

/** Flag that indicates if the rute contains toll roads.
 */
@property(nonatomic, assign) BOOL containsTollRoads;

/** Flag that indicates if the rute contains ferry lines.
 */
@property(nonatomic, assign) BOOL containsFerryLines;

/** The viapoints on the route.
 */
@property(nonatomic, strong) NSArray *viaPointsOnRoute;

/** Beta: The summary consists of a list of up to three street names locally available.
 */
@property(nonatomic, strong) NSArray *routeSummary;

@end
