//
//  SKMultiStepSearchSettings.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKDefinitions.h"

/** SKMultiStepSearchSettings stores the information for a step by step search.
 */

@interface SKMultiStepSearchSettings : NSObject

/** The hierarchy level of the search (e.g. country, state, city, street).
 */
@property(nonatomic, assign) SKListLevel listLevel;

/** The code of the country where the search is executed. When streets or house numbers are requested, this should be the code of the offline package retrieved in the previous search.
 */
@property(nonatomic, strong) NSString *offlinePackageCode;

/** The index of the parent search result (e.g. for a street this will contain the index of the city. The index is received from the previous search).
 */
@property(nonatomic, assign) unsigned long long parentIndex;

/** The search term is used to filter the results. It should be empty for all the results.
 */
@property(nonatomic, strong) NSString *searchTerm;

/** A newly initialized SKMultiStepSearchSettings.
 */
+ (instancetype)multiStepSearchSettings;

@end
