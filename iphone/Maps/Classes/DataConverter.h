#import "SwiftBridge.h"
#include "indexer/feature_decl.hpp"
#include "storage/storage.hpp"

@interface DataConverter : NSObject

+ (TripfingerMark)entityToMark:(TripfingerEntity*)entity;
+ (TripfingerEntity*)markToEntity:(TripfingerMark)mark;
+ (storage::NodeAttrs)getNodeAttrs:(string)mwmRegionId;

@end