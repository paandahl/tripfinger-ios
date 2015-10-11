//
//  SKRoutingService+GPSFiles.h
//  SKMaps
//
//  Created by Alex Ilisei on 28/03/14.
//  Copyright (c) 2014 Skobbler. All rights reserved.
//

#import "SKRoutingService.h"

@class SKGPSFileElement;

@interface SKRoutingService (GPSFiles)

/**Starts a route calculation, based on a SKGPSFileElement. The routingDelegate will receive calculation status notifications.
 @param route The settings for calculating the route. Some setting won't be used in this case, such as start and destination coordinate, because the geometry from the SKGPSFileElement will be used.
 @param element The SKGPSFileElement, result of parsing a GPS file using the SKGPSFilesService class.
 */
- (void)calculateRouteWithSettings:(SKRouteSettings *)route GPSFileElement:(SKGPSFileElement *)element;


/**Starts a route calculation, based on a predefined array of coordinates. The routingDelegate will receive calculation status notifications.
 @param route The settings for calculating the route. Some setting won't be used in this case, such as start and destination coordinate, since the route locations are predefined.
 @param locations An array of CLLocation objects that define the custom route.
 */
- (void)calculateRouteWithSettings:(SKRouteSettings *)route customLocations:(NSArray*)locations;
@end
