//
//  SKTrackablePOIRule.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>

/** SKTrackablePOIRule stores information about a POI tracking rule, used by the SKPOITracker. For detecting a POI all of the below rules should be fulfilled.
 */
@interface SKTrackablePOIRule : NSObject

/** The maximum distance on the route to the SKTrackablePOI, in order to be detected. Default value is 1500m.
 */
@property(nonatomic, assign) int routeDistance;

/** The maximum aerial distance to the SKTrackablePOI, in order to be detected. Default value is 3000m.
 */
@property(nonatomic, assign) int aerialDistance;

/** The maximum number of turns on the shortest route to the SKTrackablePOI, in order to be detected. Default value is 2.
 */
@property(nonatomic, assign) int numberOfTurns;

#pragma mark - Advanced rules
/** The GPS accuracy threshold above which the SKTrackablePOI will be ignored, in meters. Default is 100 meters.
 */
@property(nonatomic, assign) int maxGPSAccuracy;

/** The minimum speed that users must drive with to be warned about POIs around corners. Default value is 80 km/h.
 */
@property(nonatomic, assign) double minSpeedIgnoreDistanceAfterTurn;

/** The distance threshold that eliminates POIs that are far away from the last corner to them. Default value is 300 meters.
 */
@property(nonatomic, assign) int maxDistanceAfterTurn;

/** If set to YES, the tracker will eliminate SKTrackablePOIs that are placed after an U-turn. Default is YES.
 */
@property(nonatomic, assign) BOOL eliminateIfUTurn;

/** If set to YES, an audio warning will be played, via SKNavigationDelegate. Default is NO.
 */
@property(nonatomic, assign) BOOL playAudioWarning;

/** A newly initialized SKTrackablePOIRule instance.
 */
+ (instancetype)trackablePOIRule;
@end
