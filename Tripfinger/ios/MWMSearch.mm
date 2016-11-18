#import <Foundation/Foundation.h>
#import "MWMSearchEmitter.h"
#import "RCTBridgeModule.h"

#include "Framework.h"
#include "search/params.hpp"

@interface MWMSearch : NSObject <RCTBridgeModule>
@end

@implementation MWMSearch

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(search:(NSString*)query) {
  __weak auto weakSelf = self;
  search::SearchParams searchParams;
  searchParams.m_onResults = ^(search::Results const & results) {
    __strong auto self = weakSelf;
    if (!self)
      return;
    dispatch_async(dispatch_get_main_queue(), [=]() {
      if (!results.IsEndMarker()) {
        emitSearchResults(results);
      }
      else if (results.IsEndedNormal()) {
        // [self completeSearch];
      }
    });
  };
  
  searchParams.m_query = query.precomposedStringWithCompatibilityMapping.UTF8String;
  searchParams.SetForceSearch(true);
  Framework & f = GetFramework();
  searchParams.m_includeTripfingerRegions = YES;
  f.Search(searchParams);
}

RCT_EXPORT_METHOD(lastQueries:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  Framework & f = GetFramework();
  list<search::QuerySaver::TSearchRequest> lastSearches = f.GetLastSearchQueries();
  NSMutableArray *resultsArr = [[NSMutableArray alloc] init];
  for (search::QuerySaver::TSearchRequest & search : lastSearches) {
    [resultsArr addObject:@(search.second.c_str())];
  }
  resolve(resultsArr);
}

void emitSearchResults(search::Results const & results) {
  NSMutableArray *resultsArr = [[NSMutableArray alloc] init];
  
  for (int i = 0; i < results.GetCount(); i++) {
    search::Result const & result = results.GetResult(i);
    if (!result.IsSuggest()) {
      ms::LatLon latlon = MercatorBounds::ToLatLon(result.GetFeatureCenter());
      NSMutableDictionary *resultDict = [@{@"string": @(result.GetString().c_str()),
                                           @"address": @(result.GetAddress().c_str()),
                                           @"typeStr": @(result.GetFeatureType().c_str()),
                                           @"latitude": [NSNumber numberWithDouble:latlon.lat],
                                           @"longitude": [NSNumber numberWithDouble:latlon.lon],
                                           @"type": [NSNumber numberWithUnsignedInt:result.m_featureType]} mutableCopy];
      if (result.GetFeatureID().IsTripfinger()) {
        resultDict[@"tripfingerId"] = @(result.GetFeatureID().m_tripfingerId.c_str());
      } else {
        resultDict[@"featureIndex"] = [NSNumber numberWithUnsignedInt:result.GetFeatureID().m_index];
        resultDict[@"countryName"] = @(result.GetFeatureID().m_mwmId.GetInfo()->GetCountryName().c_str());
      }
      [resultsArr addObject:resultDict];
    }
  }
  NSDictionary *eventData = @{@"results": resultsArr};
  [[NSNotificationCenter defaultCenter] postNotificationName:kSearchResults object:nil userInfo:eventData];
}

@end
