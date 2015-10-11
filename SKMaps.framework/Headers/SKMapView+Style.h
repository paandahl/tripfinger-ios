//
//  SKMapView+Style.h
//  SKMaps
//
//  Copyright (c) 2014 Skobbler. All rights reserved.
//

#import "SKMapView.h"

@class SKMapViewStyle;

extern NSString *const kSKMapStyleParsingFinishedNotification;
extern NSString *const kSKMapStyleParsingFinishedStyleIDKey;

/**
 */
@interface SKMapView (Style)

/** Returns the current map style.
 */
+ (SKMapViewStyle *)mapStyle;

/** Sets the map style for all SKMapView instances.
 @param mapStyle The map style to be changed to.
 @return Success or failure of setting the new map style.
 */
+ (BOOL)setMapStyle:(SKMapViewStyle *)mapStyle;

/** Parses a new style JSON file. After the parsing is finished, the kSKMapStyleParsingFinishedNotification is sent.
 @param alternativeStyle The alternative style to be parsed.
 @param asynchronously If YES, the style will be parsed asynchronously, else it will be synchronously.
 @return Success or failure of parsing the new map style. Failure can occur if the style is not valid or if the app is in background.
 */
+ (BOOL)parseAlternativeMapStyle:(SKMapViewStyle *)alternativeStyle asynchronously:(BOOL)asynchronously;

/** Loads a parsed alternative style into memory. The alternative style is set at initialisation, using mapStyleAlternative property of SKMapsInitSettings.
 After loading use useAlternativeMapStyle: method for activating/deactivating the usage of the alternative style.
 @param alternativeStyle  The alternative style to be loaded.
 @return Success or failure of loading the new map style. Failure can occur if the style is not valid or if the app is in background.
 */
+ (BOOL)loadAlternativeMapStyle:(SKMapViewStyle *)alternativeStyle;

/** Activates/deactivates usage of alternative map style, loaded with loadAlternativeMapStyle . The alternative map style should be used if multiple and often map style changes are required ( ex: change the map to a red style when a speedcam is around , etc ).
 @param useAlternative YES in case the alternative map style should be used
 @return Success or failure of using the new map style. Failure can occur if the style is not valid or if the app is in background.
 */
+ (BOOL)useAlternativeMapStyle:(BOOL)useAlternative;

/** Unloads the alternative style from memory. ( loaded with loadAlternativeMapStyle ).
 */
+ (void)unloadAlternativeMapStyle;

/** Disposes the memory of a in memory loaded map style.
 @param alternativeStyle The alternative style to be removed.
 */
+ (void)removeStyle:(SKMapViewStyle *)alternativeStyle;

@end
