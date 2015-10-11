//
//  SKTrackablePOI.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import "SKDefinitions.h"

/** SKTrackablePOI stores information about a trackable POI, used by the SKPOITracker.
 */
@interface SKTrackablePOI : NSObject

/** The unique ID of the POI.
 */
@property(nonatomic, assign) int poiID;

/** The type of the POI. Can be used when setting rules for certain POI types.
 */
@property(nonatomic, assign) SKTrackablePOIType type;

/** The coordinate of the POI.
 */
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;

/** The heading of the POI, in degrees. The default value is -1.0, which means that the POI tracker will not take into account the heading of the trackable POI. For a different detection use values from the [ 0, 360 ] interval.
 */
@property(nonatomic, assign) double heading;

/** The street name of the SKTrackablePOI.
 */
@property(nonatomic, strong) NSString *streetName;

/** The speed limit restriction of the POI, if applicable.
 */
@property(nonatomic, assign) int speedLimit;

/** Used for storing additional information about a trackable POI.
 */
@property(nonatomic, strong) NSDictionary *userInfo;

/**A new autoreleased SKTrackablePOI instance.
 */
+ (instancetype)trackablePOI;

@end
