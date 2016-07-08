#import <UIKit/UIKit.h>

@class MWMPlacePage;

@protocol MWMPlacePageActionBarDelegate<NSObject>

- (void)addBookmark;
- (void)removeBookmark;

@end

@interface MWMPlacePageActionBar : SolidTouchView

@property (weak, nonatomic) id<MWMPlacePageActionBarDelegate> _Nullable delegate;
@property (nonatomic) BOOL isBookmark;
@property (nonatomic) BOOL isPrepareRouteMode;

@property (weak, nonatomic) IBOutlet UIButton * shareButton;

+ (MWMPlacePageActionBar *)actionBarForPlacePage:(MWMPlacePage *)placePage;
- (void)configureWithPlacePage:(MWMPlacePage *)placePage;

- (instancetype)init __attribute__((unavailable("call actionBarForPlacePage: instead")));
- (instancetype)initWithCoder:(NSCoder *)aDecoder __attribute__((unavailable("call actionBarForPlacePage: instead")));
- (instancetype)initWithFrame:(CGRect)frame __attribute__((unavailable("call actionBarForPlacePage: instead")));

@end
