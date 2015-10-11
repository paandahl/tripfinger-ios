//
//  SKRouteState.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SKCrossingDescriptor;
@class SKVisualAdviceConfiguration;

/** Holds navigation related information.
 */
@interface SKRouteState : NSObject

/** The unique identifier of the current advice.
 */
@property(nonatomic, assign) int adviceID;

/** The distance to the destination, in meters.
 */
@property(nonatomic, assign) int distanceToDestination;

/** The estimated time to the destination, in seconds.
 */
@property(nonatomic, assign) int timeToDestination;

/** The current street name.
 */
@property(nonatomic, strong) NSString *currentStreetName;

/** The next street name.
 */
@property(nonatomic, strong) NSString *nextStreetName;

/** The second street name.
 */
@property(nonatomic, strong) NSString *secondStreetName;

/** The current street type.
 */
@property(nonatomic, assign) int currentStreetType;

/** The next street type.
 */
@property(nonatomic, assign) int nextStreetType;

/** The second street type.
 */
@property(nonatomic, assign) int secondStreetType;

/** The code of the country.
 */
@property(nonatomic, strong) NSString *countryCode;

/** An array of filtered mp3 files names. The actual mp3 files are located in the SKAdvisorResources.bundle.
 */
@property(nonatomic, strong) NSArray *audioFilesFiltered;

/** An array of unfiltered mp3 files names. The actual mp3 files are located in the SKAdvisorResources.bundle.
 */
@property(nonatomic, strong) NSArray *audioFilesUnfiltered;

/** The path to the current visual advice image.
 */
@property(nonatomic, strong) NSString *currentVisualAdvicePath;

/** The distance to the current advice.
 */
@property(nonatomic, assign) int currentVisualAdviceDistance;

/** The path to the next visual advice image.
 */
@property(nonatomic, strong) NSString *secondaryVisualAdvicePath;

/** The distance to the current advice.
 */
@property(nonatomic, assign) int secondaryVisualAdviceDistance;

/** Boolean value indicating the existance of the last advice.
 */
@property(nonatomic, assign) BOOL isLastAdvice;

/** A percent representing the result of the division between the current distance to the first visual advice and the distance between the previous and the current visual advice.
 */
@property(nonatomic, assign) double currentVisualAdviceDistancePercent;

/** The current speed of the user.
 */
@property(nonatomic, assign) double currentSpeed;

/** The current speed limit.
 */
@property(nonatomic, assign) double currentSpeedLimit;

/** Indicates that the device is inside/outside a city.
 */
@property(nonatomic, assign) BOOL isInTown;

/** Contains information about how to generate the current visual advice images.
 */
@property(nonatomic, strong) SKCrossingDescriptor *firstCrossingDescriptor;

/** Contains information about how to generate the next visual advice images.
 */
@property(nonatomic, strong) SKCrossingDescriptor *secondCrossingDescriptor;

/** The number of the exit from a highway.
 */
@property(nonatomic, strong) NSString *exitNumber;

/** The instruction of the current advice.
 */
@property(nonatomic, strong) NSString *currentAdviceInstruction;

/** The instruction of the next advice.
 */
@property(nonatomic, strong) NSString *nextAdviceInstruction;

/** Reinitializes all the properties of the receiver.
 */
- (void)resetValues;

/** Generates and returns an image about the first visual advice using the given configuration.
 @param visualAdviceColor The SKVisualAdviceConfiguration is used to store the colors of a generated visual advice image.
 */
- (UIImage *)firstVisualAdviceImageWithColor:(SKVisualAdviceConfiguration *)visualAdviceColor;

/** Generates and returns an image about the second visual advice using the given configuration.
 @param visualAdviceColor The SKVisualAdviceConfiguration is used to store the colors of a generated visual advice image.
 */
- (UIImage *)secondVisualAdviceImageWithColor:(SKVisualAdviceConfiguration *)visualAdviceColor;

@end
