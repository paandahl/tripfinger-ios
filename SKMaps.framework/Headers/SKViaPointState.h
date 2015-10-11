//
//  SKViaPointState.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

/** The SKViaPointState is used to store information about a viapoint in an already calculated route.
 */
@interface SKViaPointState : NSObject

/** The unique identifier of the viapoint.
 */
@property(nonatomic, assign) int identifier;

/** Distance to arrival in meters to the viapoint.
 */
@property(nonatomic, assign) int distance;

/** The estimated time to arrival in seconds to the viapoint.
 */
@property(nonatomic, assign) int estimatedTime;

@end
