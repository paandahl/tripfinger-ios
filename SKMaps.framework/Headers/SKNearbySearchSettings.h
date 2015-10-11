//
//  SKNearbySearchSettings.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import "SKDefinitions.h"

/** SKNearbySearchSettings stores the input parameters for a nearby search.
 */
@interface SKNearbySearchSettings : NSObject

/** The center location of the searched area.
 */
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;

/** The radius of the searched area, in meters. Please pick a value from the interval of an unsigned integer(0-65535).
 */
@property(nonatomic, assign) unsigned int radius;

/** The search term is used to filter the results. It should be empty for all the results.
 */
@property(nonatomic, strong) NSString *searchTerm;

/** The connectivity mode of the search. The default value is SKSearchOnline.
 */
@property(nonatomic, assign) SKSearchMode searchMode;

/** The type of the results of the search (e.g. SKPOI, SKStreet, SKAll). The default value is SKPOI.
 */
@property(nonatomic, assign) SKSearchType searchType;

/** The results' sorting criterion. The default value is SKProximitySort.
 */
@property(nonatomic, assign) SKSearchResultSortType searchResultSortType;

/** The categories from which the results will be retrieved (NSNumber objects). Use the default value for getting all of the results.
 */
@property(nonatomic, strong) NSArray *searchCategories;

/** A newly initialized SKNearbySearchSettings.
 */
+ (instancetype)nearbySearchSettings;

@end
