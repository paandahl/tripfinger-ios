#import "DataConverter.h"
#include "geometry/mercator.hpp"

@implementation DataConverter

+ (TripfingerMark)entityToMark:(TripfingerEntity*)entity
{
  TripfingerMark mark = {};
  mark.mercator = MercatorBounds::FromLatLon(entity.lat, entity.lon);
  mark.name = [entity.name UTF8String];
  
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

@end