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
