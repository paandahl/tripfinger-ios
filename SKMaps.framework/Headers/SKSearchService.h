//
//  SKSearchService.h
//  ForeverMapNGX
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKSearchServiceDelegate.h"
#import "SKDefinitions.h"

@class SKMultiStepSearchSettings;
@class SKNearbySearchSettings;

/** SKSearchService class provides services for searching POIs and addresses.
 SKSearchService supports one search at a time. If multiple search requests were started, only the latest request will be processed.
 */
@interface SKSearchService : NSObject

/** Returns the singleton SKSearchService instance.
 */
+ (instancetype)sharedInstance;

/** The delegate that must conform to SKSearchServiceDelegate protocol, used for receiving search results.
 */
@property(atomic, weak) id<SKSearchServiceDelegate> searchServiceDelegate;

/** The maximum number of search results that will be returned by a search. The default value is 20.
 */
@property(nonatomic, assign) int searchResultsNumber;

/** The language in which the search results are returned. The default value is SKMapLanguageEN.
 */
@property(nonatomic, assign) SKLanguage searchLanguage;

/** The POI categories hierarchy. The keys are the main categories (SKPOIMainCategory) and the values are arrays of subcategories (SKPOICategory).
 */
@property(nonatomic, readonly, strong) NSDictionary *categoriesFromMainCategories;

/** Starts a multi-step search. It works only offline with data from offline packages.
 For geocoding an address, multiple steps are required: choosing the country, then the city, then the street, all from a previously retrieved list.
 The results will be retrieved on the searchService:didRetrieveMultiStepSearchResults: method of the SKSearchServiceDelegate protocol.
 For more information about search parameters, check SKMultiStepSearchSettings.
 @param multiStepObject Specifies the search settings.
 @return The status of starting the search operation.
 */
- (SKMapSearchStatus)startMultiStepSearchWithSettings:(SKMultiStepSearchSettings *)multiStepObject;

/** Starts a nearby search for streets and POIs around a coordinate.
 The results will be retrieved on the searchService:didRetrieveNearbySearchResults:withSearchMode: method of the SKSearchServiceDelegate protocol.
 For more information about search parameters, check SKNearbySearchSettings.
 @param nearbySearchObject Specifies the search settings.
 @return The status of starting the search operation.
 */
- (SKMapSearchStatus)startNearbySearchWithSettings:(SKNearbySearchSettings *)nearbySearchObject;

/** Cancels the ongoing search request.
 */
- (void)cancelSearch;

@end
