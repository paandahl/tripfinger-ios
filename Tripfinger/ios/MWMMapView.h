#import "EAGLView.h"
#import "RCTViewManager.h"

@interface MWMMapView : EAGLView

@property (nonatomic, copy) RCTBubblingEventBlock onMapObjectSelected;
@property (nonatomic, copy) RCTBubblingEventBlock onMapObjectDeselected;

+ (instancetype)sharedInstance;

@end
