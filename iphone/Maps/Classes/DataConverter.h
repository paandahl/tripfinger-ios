#import "SwiftBridge.h"
#include "indexer/feature_decl.hpp"

@interface DataConverter : NSObject

+ (TripfingerMark)entityToMark:(TripfingerEntity*)entity;
+ (TripfingerEntity*)markToEntity:(TripfingerMark)mark;

@end