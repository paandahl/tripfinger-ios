//
//  SKMapCustomPOI.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKDefinitions.h"

/** The SKMapCustomPOI is used for presenting custom POIs visually on the map view. The icons that will be used are defined in the map style JSON file, based on different POI categories and types. The SKMapCustomPOI icons will be dynamically clustered when needed.
 */
@interface SKMapCustomPOI : NSObject

/** The unique identifier of the custom POI.
 */
@property(nonatomic, assign) int identifier;

/** The coordinate where the custom POI should be added.
 */
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;

/** The type of the custom POI. The icons for each POI type are defined in the map style JSON file.
 */
@property(nonatomic, assign) SKPOIType type;

/** It describes what category the POI belongs to (e.g. bar, pub, hotel, etc.).
 */
@property(nonatomic, assign) SKPOICategory categoryID;

/** The minimum zoom level on which the POI should be visible.
 */
@property(nonatomic, assign) int minZoomLevel;

/** A newly initialized SKMapCustomPOI.
 */
+ (instancetype)mapCustomPOI;

@end
