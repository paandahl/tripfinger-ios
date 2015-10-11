//
//  SKPositionerService.h
//  ForeverMapNGX
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import <CoreLocation/CLLocationManager.h>

#import "SKDefinitions.h"
#import "SKPositionerServiceDelegate.h"

/** SKPositionerService is used for managing GPS position related operations.
 */
@interface SKPositionerService : NSObject

/** The delegate that must conform to SKPositionerServiceDelegate protocol, used for receiving different GPS location updates.
 */
@property(nonatomic, weak) id<SKPositionerServiceDelegate> delegate;

/** The positioner mode. The positioner can use real positions or simulated positions using reportGPSPosition method. The default value is  SKPositionerModeRealPositions.
 */
@property(nonatomic, assign) SKPositionerMode positionerMode;

/** The activity type of the location positioner.
 */
@property(nonatomic, assign) CLActivityType activityType;

/** Indicates whether the positioner will still work when the client application is in background. Default value is NO. If the client still requires positions when the app is in backgorund, set to YES.
 */
@property(nonatomic, assign) BOOL worksInBackground;

/** Allow or forbid location update pause when movement is not detected. This is useful for optimizing battery life. Default is YES.
    If this property is YES, battery life can be prolonged but if the app is in background it may be completely suspended after a while, thus it may be undesirable for background navigation.
    If the property is NO, the battery life may suffer but your app will receive location updates even if the device is stationary.
    In a real life situation it is recommended that this property is YES because if the the app is in background it will be resumed periodically, whenever the location is updated.
 */
@property(nonatomic, assign) BOOL automaticLocationUpdatePause;

/** The overall accuracy of the latest received GPS positions.
 */
@property(nonatomic, readonly, assign) SKGPSAccuracyLevel gpsAccuracyLevel;

/** Last GPS coordinate reported by the device.
 */
@property(nonatomic, readonly, assign) CLLocationCoordinate2D currentCoordinate;

/** The current  position stored by the library, matched on a road segment, in the SKPosition format.
 */
@property(nonatomic, readonly, assign) SKPosition currentMatchedPosition;

/** Last heading information reported by the location manager.
 */
@property(nonatomic, readonly, assign) CLHeading *currentHeading;

/** Current speed information reported by the location manager.
 */
@property(nonatomic, readonly, assign) double currentSpeed;

/** Path to the log file to be used for simulating a navigation.
 */
@property(nonatomic, strong) NSString *positionsLogFilePath;

/** Returns the singleton SKPositionerService instance.
 */
+ (instancetype)sharedInstance;

/** Starts updating GPS locations. In order to receive GPS locations, the following key must be added in the project's plist file:
 NSLocationWhenInUseUsageDescription. The value of the key will be displayed to the user when he accepts/declines location updates for the application. If the key and the value are not added to the plist file, the user will not be asked for permission and the current position will not be available in the SDK.
 */
- (void)startLocationUpdate;

/** Stops updating GPS locations.
 */
- (void)cancelLocationUpdate;

/** Starts updating only significant GPS locations.
 */
- (void)startSignificantLocationUpdate;

/** Stops updating only significant GPS locations.
 */
- (void)cancelSignificantLocationUpdate;

#pragma mark - Position simulation

/** Reports GPS locations in order to simulate the current position. The positionerMode property needs to previously be set to SKPositionerModePositionSimulation.
 @param location The location that will be used as current position. In order to set a custom heading, use the course property of CLLocation.
 */
- (void)reportGPSLocation:(CLLocation*)location;

/** Starts replaying a log file that was previously recorded. Positions saved there will be used instead of those received from the GPS hardware.
 @param logFileNameWithPath The path to the log file.
 @return Success/Failure of the operation.
 */
- (BOOL)startPositionReplayFromLog:(NSString *)logFileNameWithPath;

/** Stops the replaying of GPS positions.
 @return Success/Failure of the operation.
 */
- (BOOL)stopPositionReplay;

/** Sets the position replaying rate. The time interval between the replay of positions is shortened directly proportional to the rate.
 @param rate The rate of replaying.
 @return Success/Failure of the operation.
 */
- (BOOL)setPositionReplayRate:(double)rate;

/** Increases the current speed of the user during a navigation simulation with the given value in m/s.
 @param withValue The value to increase the current speed in m/s.
 @return Success/Failure of the operation.
 */
- (BOOL)increaseRouteSimulationSpeed:(int)withValue;

/** Decreases the current speed of the user during a navigation simulation with the given value in m/s.
 @param withValue The value to increase the current speed in m/s.
 @return Success/Failure of the operation.
 */
- (BOOL)decreaseRouteSimulationSpeed:(double)withValue;

/** Returns the elevation in meters at the given location. Returns 0 if the tiles for that location are not yet loaded.
 @param coordinate Location where the elevation is returned.
 */
- (void)requestElevationAtCoordinate:(CLLocationCoordinate2D)coordinate;

@end
