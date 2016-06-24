#import "DataConverter.h"
#include "geometry/mercator.hpp"
#include "search/v2/search_model.hpp"

@implementation DataConverter

+ (TripfingerMark)entityToMark:(TripfingerEntity*)entity
{
  TripfingerMark mark = {};
  mark.mercator = MercatorBounds::FromLatLon(entity.lat, entity.lon);
  mark.name = [entity.name UTF8String];
  
  mark.category = entity.category;
  mark.type = entity.type;
  mark.tripfingerId = [entity.tripfingerId UTF8String];
  
  mark.phone = [entity.phone UTF8String];
  mark.address = [entity.address UTF8String];
  mark.website = [entity.website UTF8String];
  mark.email = [entity.email UTF8String];
  
  mark.content = [entity.content UTF8String];
  mark.price = [entity.price UTF8String];
  mark.openingHours = [entity.openingHours UTF8String];
  mark.directions = [entity.directions UTF8String];
  
  mark.url = [entity.url UTF8String];
  mark.imageDescription = [entity.imageDescription UTF8String];
  mark.license = [entity.license UTF8String];
  mark.artist = [entity.artist UTF8String];
  mark.originalUrl = [entity.originalUrl UTF8String];
  
  if (entity.category == 130) {
    mark.searchType = search::v2::SearchModel::SearchType::SEARCH_TYPE_COUNTRY;
  } else {
    mark.searchType = search::v2::SearchModel::SearchType::SEARCH_TYPE_POI;
  }
  mark.offline = entity.offline;
  mark.liked = entity.liked;
  
  return mark;
}

+ (TripfingerEntity*)markToEntity:(TripfingerMark)mark
{
  TripfingerEntity* entity = [[TripfingerEntity alloc] init];
  ms::LatLon latLon = MercatorBounds::ToLatLon(mark.mercator);
  entity.lat = latLon.lat;
  entity.lon = latLon.lon;
  entity.name = [NSString stringWithUTF8String:mark.name.c_str()];
  
  entity.category = mark.category;
  entity.type = mark.type;
  entity.tripfingerId = [NSString stringWithUTF8String:mark.tripfingerId.c_str()];
  
  entity.phone = [NSString stringWithUTF8String:mark.phone.c_str()];
  entity.address = [NSString stringWithUTF8String:mark.address.c_str()];
  entity.website = [NSString stringWithUTF8String:mark.website.c_str()];
  entity.email = [NSString stringWithUTF8String:mark.email.c_str()];
  
  entity.content = [NSString stringWithUTF8String:mark.content.c_str()];
  entity.price = [NSString stringWithUTF8String:mark.price.c_str()];
  entity.openingHours = [NSString stringWithUTF8String:mark.openingHours.c_str()];
  entity.directions = [NSString stringWithUTF8String:mark.directions.c_str()];
  
  entity.url = [NSString stringWithUTF8String:mark.url.c_str()];
  entity.imageDescription = [NSString stringWithUTF8String:mark.imageDescription.c_str()];
  entity.license = [NSString stringWithUTF8String:mark.license.c_str()];
  entity.artist = [NSString stringWithUTF8String:mark.artist.c_str()];
  entity.originalUrl = [NSString stringWithUTF8String:mark.originalUrl.c_str()];
  
  entity.offline = mark.offline;
  entity.liked = mark.liked;
  
  return entity;
}

+ (storage::NodeAttrs)getNodeAttrs:(string)mwmRegionId
{
  storage::NodeAttrs nodeAttrs;
  nodeAttrs.m_downloadingMwmCounter = 0;
  NSString* realCountryId = [@(mwmRegionId.c_str()) substringFromIndex:5];
  NSInteger downloadStatus = [TripfingerAppDelegate downloadStatus:realCountryId];
  nodeAttrs.m_status = static_cast<storage::NodeStatus>(downloadStatus);
  if (nodeAttrs.m_status == storage::NodeStatus::Downloading) {    
    nodeAttrs.m_downloadingProgress.first = 1;
    nodeAttrs.m_downloadingProgress.second = 100;
  }
  if (nodeAttrs.m_status == storage::NodeStatus::NotDownloaded) {
    nodeAttrs.m_nodeLocalName = "Download guide";
  } else {
    nodeAttrs.m_nodeLocalName = "Guide content";
  }
  nodeAttrs.m_mwmSize = [TripfingerAppDelegate countrySize:realCountryId];
  return nodeAttrs;
}

@end