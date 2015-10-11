//
//  SKGPSFilesService.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKGPSFileElement.h"

/** SKGPSFilesService provides support for loading, parsing and editing GPS files.
 Currently supports only the GPX file format.
 */
@interface SKGPSFilesService : NSObject

/** Returns the singleton SKGPSFilesService instance.
 */
+ (SKGPSFilesService *)sharedInstance;

/** Loads a GPS file at a certain path and return the root element.
 @param path The path where the GPS file is located.
 @param error A pointer to an NSError object (not mandatory). If an error occurs, this will contain the failure reason.
 @return The root SKGPSFileElement. This can be used to navigate through the GPS file structure.
 */
- (SKGPSFileElement *)loadFileAtPath:(NSString *)path error:(NSError * *)error;

/** Saves the current loaded GPS file to a certain path.
 @param path The path where the GPS file will be saved.
 @param error A pointer to an NSError object (not mandatory). If an error occurs, this will contain the failure reason.
 @return Success/Failure of saving the GPS data file.
 */
- (BOOL)saveFileAtPath:(NSString *)path error:(NSError * *)error;

/** Resets the current loaded GPS file to the initial state.
 @param error A pointer to an NSError object (not mandatory). If an error occurs, this will contain the failure reason.
 @return Success/Failure of resetting the GPS data file.
 */
- (BOOL)resetCurrentFile:(NSError * *)error;

/** Returns all the children elements of a parent element
 @param parent The parent element.
 @param error A pointer to an NSError object (not mandatory). If an error occurs, this will contain the failure reason.
 @return An array of SKGPSFileElement objects, children of the parent element.
 */
- (NSArray *)childElementsForElement:(SKGPSFileElement *)parent error:(NSError * *)error;

/** Returns all the children elements with a certain type of a parent element.
 @param parent The parent element.
 @param type The type of the child elements.
 @param error A pointer to an NSError object (not mandatory). If an error occurs, this will contain the failure reason.
 @return An array of SKGPSFileElement objects with the specified type, children of the parent element.
 */
- (NSArray *)childElementsForElement:(SKGPSFileElement *)parent withType:(SKGPSFileElementType)type error:(NSError * *)error;

/** Returns the GPS locations of a SKGPSFileElement.
 @param element The element of the GPS file.
 @return An array of CLLocation objects, representing the locations of a SKGPSFileElement. For some element types ( SKGPSFileElementGPXRoutePoint, SKGPSFileElementGPXTrackPoint, SKGPSFileElementGPXWaypoint ), it will contain only one object .
 */
- (NSArray *)locationsForElement:(SKGPSFileElement *)element;


@end
