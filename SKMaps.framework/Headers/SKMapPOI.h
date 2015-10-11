//
//  SKMapPOI.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKDefinitions.h"

@class SKWikiTravelPOIDetails;

/** SKMapPOI stores the information about an embedded map POI.
 */
@interface SKMapPOI : NSObject

/** It describes what category the POI belongs to (e.g. bar, pub, hotel, etc.).
 */
@property(nonatomic, assign) SKPOICategory category;

/** The name of the map POI.
 */
@property(nonatomic, strong) NSString *name;

/** The coordinate of the map POI.
 */
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;

/** Array with the search results' parents (SKSearchResultParent objects). e.g. for a street, it will contain: country, state and city.
 */
@property(nonatomic, strong) NSArray *parentSearchResults;

/** A newly initialized SKMapPOI.
 */
+ (instancetype)mapPOI;

@end
