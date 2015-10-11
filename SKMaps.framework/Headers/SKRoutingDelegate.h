//
//  SKRoutingDelegate.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKDefinitions.h"

@class SKRoutingService, SKRouteInformation;

/** The routing delegate of the SKRoutingService must adopt the SKRoutingDelegate protocol. The SKRoutingDelegate protocol is used to receive routing related update messages.
 */
@protocol SKRoutingDelegate <NSObject>

@optional

/** Called when a route is succesfully calculated including a requested route alternative. 
 Note: For long routes, this callback might be called twice for the same route. The reason is that a potential turn by turn navigation can start without calculating the route completely and downloading all the required map tiles. To check if the route is completely finished you should  check if routeInformation.corridorIsDownloaded is YES.
 @param routingService The routing service.
 @param routeInformation An object that contains information regarding the calculated route.
 */
- (void)routingService:(SKRoutingService *)routingService didFinishRouteCalculationWithInfo:(SKRouteInformation *)routeInformation;

/** Called when the route cannot be calculated.
 @param routingService The routing service.
 @param errorCode The error code of the failure.
 */
- (void)routingService:(SKRoutingService *)routingService didFailWithErrorCode:(SKRoutingErrorCode)errorCode;

/** Called when all the routes including alternatives are calculated. Not all the times the required number of alternatives can be calculated, because the routes may be too similar. This callback is called when no more route alternatives will be provided.
 @param routingService The routing service.
 */
- (void)routingServiceDidCalculateAllRoutes:(SKRoutingService *)routingService;

/** Called during the route calculation process. If the route cannot be calculated because of a connectivity issue, this callback can be used to control the retry mechanism. Id it's not implemented the route calculation will be retried until successful.
 @param routingService The routing service.
 @param timeInterval The time interval since the route calculation is hanging in seconds.
 @return A boolean value which indicates if the route calculation should be retried.
 */
- (BOOL)routingServiceShouldRetryCalculatingRoute:(SKRoutingService *)routingService withRouteHangingTime:(int)timeInterval;


@end
