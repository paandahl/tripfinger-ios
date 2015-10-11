//
//  SKSearchResult.h
//  ForeverMapNGX
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKDefinitions.h"

/** SKSearchResult stores the information for a search result retrieved by a search.
 */
@interface SKSearchResult : NSObject

/** Describes what the search object represents (country, state, city, street, POI, etc.).
 */
@property(nonatomic, assign) SKSearchResultType type;

/** The unique id of the object.
 */
@property(nonatomic, assign) unsigned long long identifier;

/** The name of the search result.
 */
@property(nonatomic, strong) NSString *name;

/** Array with the search results' parents (SKSearchResultParent objects). e.g. for a street, it will contain: country, state and city.
 */
@property(nonatomic, strong) NSArray *parentSearchResults;

/** The coordinate of the search result.
 */
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;

/** Available only for POIs. It describes what category the POI belongs to (e.g. bar, pub, hotel, etc.).
 */
@property(nonatomic, assign) SKPOICategory category;

/** Available only for POIs. It describes what main category the POI belongs to. While there are hundreds of categories, only few main categories are defined, for clearer categorization.
 */
@property(nonatomic, assign) SKPOIMainCategory mainCategory;

/** The code of the offline package containing the map data (e.g. "FR", "DE", "ROCITY01", etc.). Needed when performing offline geocoding.
 */
@property(nonatomic, strong) NSString *offlinePackageCode;

/**A newly initialized SKSearchResult.
 */
+ (instancetype)searchResult;

@end
