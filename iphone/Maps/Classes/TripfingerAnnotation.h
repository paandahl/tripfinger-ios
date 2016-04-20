//
//  TripfingerAnnotation.h
//  Maps
//
//  Created by Preben Ludviksen on 12/04/16.
//  Copyright © 2016 MapsWithMe. All rights reserved.
//

#ifndef TripfingerAnnotation_h
#define TripfingerAnnotation_h

@interface TripfingerAnnotation:NSObject
{
}

@property(nonatomic, readwrite) double lat;
@property(nonatomic, readwrite) double lon;
@property NSString *name;
@property int identifier;
@property int type;

@end

#endif /* TripfingerAnnotation_h */
