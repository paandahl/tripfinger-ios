#import "EAGLView.h"
#import "RCTViewManager.h"

@interface MWMMapView : EAGLView

@property (nonatomic, copy) NSDictionary* location;
@property (nonatomic, assign) double heading;
@property (nonatomic, copy) RCTBubblingEventBlock onMapObjectSelected;
@property (nonatomic, copy) RCTBubblingEventBlock onMapObjectDeselected;
@property (nonatomic, copy) RCTBubblingEventBlock onLocationStateChanged;

+ (instancetype)sharedInstance;
- (void)onEnterBackground;
- (void)onTerminate;
- (void)onGetFocus:(BOOL)isOnFocus;

@end
