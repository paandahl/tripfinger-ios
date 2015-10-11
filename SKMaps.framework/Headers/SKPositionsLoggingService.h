//
//  SKPositionsLoggingService.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKDefinitions.h"

@class SKCoordinate;

/** Service for logging the device's GPS positions to a file, in different formats ( LOG and GPX ). After calling startLoggingPositionsToFileAtPath:withLoggingType:, make sure you also call stopLoggingPositions.
 Otherwise, GPX tags won't properly close and the saved file might be corrupted.
 */
@interface SKPositionsLoggingService : NSObject

/** Returns the singleton SKPositionsLoggingService instance.
 */
+ (instancetype)sharedInstance;

/** Starts logging device positions to a file at a specified path.
 @param filePath The path to a file ( with no extension ) that the logger will write in. The file will be created if it doesn't exist.
 @param loggingType The format of the logged positions ( GPX or LOG ). Based on this parameter, a proper file extension will be added to the file.
 @return Succes/Failure of the operation.
 */
- (BOOL)startLoggingPositionsToFileAtPath:(NSString *)filePath withLoggingType:(SKPositionsLoggingType)loggingType;

/** Adds a custom waypoint to the current logging file.
 @param waypoint The custom object to be added.
 @return Succes/Failure of the operation.
 */
- (BOOL)addWaypointToCurrentLoggingFile:(SKCoordinate *)waypoint;

/** Pauses logging to current file.
 @return Succes/Failure of the operation.
 */
- (BOOL)pauseLoggingPositions;

/** Resumes logging to current file, after a pause.
 @return Succes/Failure of the operation.
 */
- (BOOL)resumeLoggingPositions;

/** Stops logging to current file. This closes any GPX opened tags and closes the file. It's mandatory to be called, after a startLoggingPositionsToFileAtPath:withLoggingType: call.
 @return Succes/Failure of the operation.
 */
- (BOOL)stopLoggingPositions;

@end
