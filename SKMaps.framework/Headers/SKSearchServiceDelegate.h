//
//  SKSearchServiceDelegate.h
//  ForeverMapNGX
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKDefinitions.h"

@class SKSearchService;

/**The SKSearchServiceDelegate defines a set of optional methods that you can be used to receive search results. The SKSearchService class uses these methods to notify the caller objects when a specific search operation finished. The searches happen asynchronously, but these callbacks are called on the main thread.
 */
@protocol SKSearchServiceDelegate <NSObject>
@optional

/** Called for a successfull step by step search operation.
 @param searchService The search service.
 @param searchResults Contains the step by step search results (a list of SKSearchResult objects).
 */
- (void)searchService:(SKSearchService *)searchService didRetrieveMultiStepSearchResults:(NSArray *)searchResults;

/** Called for a failed step by step search operation.
 @param searchService The search service.
 */
- (void)searchServiceDidFailToRetrieveMultiStepSearchResults:(SKSearchService *)searchService;

/** Called for a successfull nearby search operation.
 @param searchService The search service.
 @param searchResults Contains the nearby search results (a list of SKSearchResult objects).
 @param searchMode Specifies the search type (SKSearchOnline if the search results were returned after an online search, SKSearchOffline if the search results were returned after an offline search).
 */
- (void)searchService:(SKSearchService *)searchService didRetrieveNearbySearchResults:(NSArray *)searchResults withSearchMode:(SKSearchMode)searchMode;

/** Called for a failed nearby search operation.
 @param searchService The search service.
 @param searchMode Specifies the search type (SKSearchOnline if the online search failed, SKSearchOffline if the offline search failed).
 */
- (void)searchService:(SKSearchService *)searchService didFailToRetrieveNearbySearchResultsWithSearchMode:(SKSearchMode)searchMode;

@end
