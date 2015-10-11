//
//  SKPOITracker.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKDefinitions.h"
#import <CoreLocation/CLLocation.h>

@class SKTrackablePOI, SKTrackablePOIRule, SKPOITracker;

/** SKPOITrackerDataSource protocol is used for providing SKTrackablePOI objects to the SKPoiTracker.
 */
@protocol SKPOITrackerDataSource <NSObject>
@required
/** Provides SKTrackablePOI objects to the SKPOITracker. It will be called based on the parameters set to the startPOITrackerWithRadius:refreshMargin: of the SKPOITracker.
 @param poiTracker The POI tracker.
 @param location The center coordinate of the area where SKTrackablePOI objects are requested.
 @param radius The radius of the area where SKTrackablePOI objects are requested, previously set when starting the SKPOITracker.
 @param poiType The type of the POIs.
 @return An array of SKTrackablePOI objects, that can be detected in the requested area.
 */
- (NSArray *)poiTracker:(SKPOITracker *)poiTracker trackablePOIsAroundLocation:(CLLocationCoordinate2D)location inRadius:(int)radius withType:(int)poiType;
@end


/** SKPOITrackerDelegate is used for notifying the POIs that the SKPOITracker detected.
 */
@protocol SKPOITrackerDelegate <NSObject>
@optional
/** Called when POIs provided by the SKPOITrackerDataSource are detected by the SKPOITracker. Continuously called during a tracking session.
 @param poiTracker The POI tracker.
 @param detectedPOIs An array of SKDetectedPOI objects representing the detected POIs.
 @param type The type of the POIs which were detected.
 */
- (void)poiTracker:(SKPOITracker *)poiTracker didDectectPOIs:(NSArray *)detectedPOIs withType:(int)type;
@end


/** SKPOITracker is used for tracking points of interest during a navigation. It has a dataSource, that provides POIs to the tracker, and a delegate, that will be notified which POIs are detected, based on a set of custom detection rules.
 SKPOITracker works during a navigation session only. Check the SKRoutingService for further details.
 */
@interface SKPOITracker : NSObject

#pragma mark Delegate & DataSource
/** SKPOITracker's dataSource, provides data to the SKPOITracker. Check SKPOITrackerDataSource's documentation for more details.
 */
@property(nonatomic, weak) id<SKPOITrackerDataSource> dataSource;
/** SKPOITracker's delegate, gets notified for detected POIs. Check SKPOITrackerDelegate's documentation for more details.
 */
@property(nonatomic, weak) id<SKPOITrackerDelegate> delegate;

#pragma mark Tracking

/** Returns the singleton SKRoutingService instance.
 */
+ (instancetype)sharedInstance;

/** Starts the POIs detection. The detection process can be customised using custom detection rules. The detection works during a navigation session only. Check the SKRoutingService for further details.
 @param radius The radius of the POI coverage area. The dataSource will have to provide POIs in this radius when needed.
 @param refreshMargin The percentage of outer coverage area that triggers a refresh when reached, using the dataSource. Has to be in the [ 0.0, 0.5 ] interval.
 @param poiTypes An array of NSNumber objects, indicating the types of POIs which should be detected. The trackablePOIsAroundLocation:inRadius:withType datasource will be called for each type from the array.
 */
- (void)startPOITrackerWithRadius:(int)radius refreshMargin:(double)refreshMargin forPOITypes:(NSArray *)poiTypes;

/** Stops the POI detection.
 */
- (void)stopPOITracker;

#pragma mark Detection rules
/** Sets a rule for a certain POI type. For more details about rules please check the SKTrackablePOIRule's documentation. All the rules defined by a SKTrackablePOIRule must be accomplished in order to detect a SKTrackablePOI.
 @param rule The rule that will be used.
 @param type The type of SKTrackablePOIs that the rule will apply to.
 */
- (void)setRule:(SKTrackablePOIRule *)rule forPOIType:(SKTrackablePOIType)type;

/** Returns the rule used for a certain SKTrackablePOIType in detection. For more details about rules please check the SKTrackablePOIRule's documentation.
 @param type The type of the rule.
 @return The rule that is used for this type of SKTrackablePOI in detection.
 */
- (SKTrackablePOIRule *)ruleForPOIType:(SKTrackablePOIType)type;

/** Configures the audio adviser.
 @param type The type of SKTrackablePOIs for what the configuration will apply to.
 @param filePath The path to the file which contains the data for the configuration of the adviser. Set to Nil for using the default configuration.
 */
- (void)setWarningRulesForType:(SKTrackablePOIType)type withFilePath:(NSString *)filePath;

#pragma mark Force Update
/** Triggers the dataSource's poiTracker:trackablePOIsAroundLocation:inRadius: instantly, even if the refreshMargin is not reached.
 Useful when the data source is updated.
 */
- (void)forceUpdateTrackedPOIs;

#pragma mark Utils

/** Returns POIs located on the current route from the given array.
 @param providedPOIs Array of POIs to be filtered.
 @return The array of POIs located on the route.
 */
- (NSArray *)trackablePOIsOnRoute:(NSArray *)providedPOIs;

@end
