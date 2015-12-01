//
//  SKRouteAdvice.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CLLocation.h>
#import "SKDefinitions.h"

@class SKVisualAdviceConfiguration, SKCrossingDescriptor;

/**SKRouteAdvice stores information about a route advice.
 */
@interface SKRouteAdvice : NSObject

/** Unique ID of the advice.
 */
@property(nonatomic, assign) int adviceID;

/** Time left to reach the destination, in seconds.
 */
@property(nonatomic, assign) int timeToDestination;

/** Distance to destination, in the desired format.
 */
@property(nonatomic, assign) int distanceToDestination;

/** Distance between the previous and the current advice, in meters.
 */
@property(nonatomic, assign) int distanceToAdvice;

/** Time between the previous and the current advice, in seconds.
 */
@property(nonatomic, assign) int timeToAdvice;

/** The street after the advice.
 */
@property(nonatomic, strong) NSString *streetName;

/** Path to the visual advice file generated on the disk.
 */
@property(nonatomic, strong) NSString *visualAdviceFile;

/** The playlist for the advice, containing NSString objects with the names of audio .mp3 files.
 */
@property(nonatomic, strong) NSMutableArray *audioFilePlaylist;

/** The sentence of the instructions.
 */
@property(nonatomic, strong) NSString *adviceInstruction;

/** The GPS coordinate of the advice.
 */
@property(nonatomic, assign) CLLocationCoordinate2D location;

/** The type of the street.
 */
@property(nonatomic, assign) SKStreetType streetType;

/** The code of the country.
 */
@property(nonatomic, strong) NSString *countryCode;

/** Contains information about how to generate the  visual advice images.
 */
@property(nonatomic, strong) SKCrossingDescriptor *crossingDescriptor;

/* Indicates the side of the street where destination point is.
 */
@property(nonatomic, assign) SKDestinationSide destinationSide;

/** The functional classification of a road is the class, or group, of roads that the road belongs to. Roads with functional class FunctionalClassification1 are the most important, fastest roads.(e.g. highways)
 */
@property(nonatomic, assign) SKRoadFunctionalClass roadFunctionalClass;

/** Provides information about the direction of the turn.
 */
@property(nonatomic, assign) SKStreetDirection streetDirection;

@end
