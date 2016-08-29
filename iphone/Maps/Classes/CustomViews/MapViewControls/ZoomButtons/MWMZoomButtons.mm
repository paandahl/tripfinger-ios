#import "MWMZoomButtons.h"
#import "MWMZoomButtonsView.h"
#import "Statistics.h"
#import "MWMButton.h"

#import "3party/Alohalytics/src/alohalytics_objc.h"

#include "Framework.h"
#include "platform/settings.hpp"
#include "indexer/scales.hpp"

static NSString * const kMWMZoomButtonsViewNibName = @"MWMZoomButtonsView";

extern NSString * const kAlohalyticsTapEventKey;

namespace
{  
  NSArray<UIImage *> * animationImages(NSString * animationTemplate, NSUInteger imagesCount)
  {
    NSMutableArray<UIImage *> * images = [NSMutableArray arrayWithCapacity:imagesCount];
    NSString * mode = @"light";
    for (NSUInteger i = 1; i <= imagesCount; i += 1)
    {
      NSString * name =
      [NSString stringWithFormat:@"%@_%@_%@", animationTemplate, mode, @(i).stringValue];
      [images addObject:[UIImage imageNamed:name]];
    }
    return images.copy;
  }
}  // namespace

@interface MWMZoomButtons()

@property (nonatomic) IBOutlet MWMZoomButtonsView * zoomView;
@property (weak, nonatomic) IBOutlet UIButton * zoomInButton;
@property (weak, nonatomic) IBOutlet UIButton * zoomOutButton;
@property (weak, nonatomic) IBOutlet MWMButton * locationButton;

@property (nonatomic) BOOL zoomSwipeEnabled;
@property (nonatomic, readonly) BOOL isZoomEnabled;

@property (nonatomic) location::EMyPositionMode locationMode;

@end

@implementation MWMZoomButtons

- (instancetype)initWithParentView:(UIView *)view
{
  self = [super init];
  if (self)
  {
    [[NSBundle mainBundle] loadNibNamed:kMWMZoomButtonsViewNibName owner:self options:nil];
    [view addSubview:self.zoomView];
    [self.zoomView layoutIfNeeded];
    self.zoomView.topBound = 0.0;
    self.zoomView.bottomBound = view.height;
    self.zoomSwipeEnabled = NO;
  }
  return self;
}

- (void)setTopBound:(CGFloat)bound
{
  self.zoomView.topBound = bound;
}

- (void)setBottomBound:(CGFloat)bound
{
  self.zoomView.bottomBound = bound;
}

- (void)zoomIn
{
  [Statistics logEvent:kStatEventName(kStatZoom, kStatIn)];
  [Alohalytics logEvent:kAlohalyticsTapEventKey withValue:@"+"];
  GetFramework().Scale(Framework::SCALE_MAG, true);
}

- (void)zoomOut
{
  [Statistics logEvent:kStatEventName(kStatZoom, kStatOut)];
  [Alohalytics logEvent:kAlohalyticsTapEventKey withValue:@"-"];
  GetFramework().Scale(Framework::SCALE_MIN, true);
}

- (void)mwm_refreshUI
{
  [self.zoomView mwm_refreshUI];
  [self.locationButton.imageView stopAnimating];
  [self refreshLocationButtonState:self.locationMode];
}

#pragma mark - Location button

- (void)processMyPositionStateModeEvent:(location::EMyPositionMode)mode
{
  UIButton * locBtn = self.locationButton;
  [locBtn.imageView stopAnimating];
  
  NSArray<UIImage *> * images =
  ^NSArray<UIImage *> *(location::EMyPositionMode oldMode, location::EMyPositionMode newMode)
  {
    switch (newMode)
    {
      case location::MODE_NOT_FOLLOW:
      case location::MODE_UNKNOWN_POSITION:
        if (oldMode == location::MODE_ROTATE_AND_FOLLOW)
          return animationImages(@"btn_follow_and_rotate_to_get_position", 3);
        else if (oldMode == location::MODE_FOLLOW)
          return animationImages(@"btn_follow_to_get_position", 3);
        return nil;
      case location::MODE_FOLLOW:
        if (oldMode == location::MODE_ROTATE_AND_FOLLOW)
          return animationImages(@"btn_follow_and_rotate_to_follow", 3);
        else if (oldMode == location::MODE_NOT_FOLLOW || oldMode == location::MODE_UNKNOWN_POSITION)
          return animationImages(@"btn_get_position_to_follow", 3);
        return nil;
      case location::MODE_PENDING_POSITION: return nil;
      case location::MODE_ROTATE_AND_FOLLOW:
        if (oldMode == location::MODE_FOLLOW)
          return animationImages(@"btn_follow_to_follow_and_rotate", 3);
        return nil;
    }
  }
  (self.locationMode, mode);
  locBtn.imageView.animationImages = images;
  if (images)
  {
    locBtn.imageView.animationDuration = 0.0;
    locBtn.imageView.animationRepeatCount = 1;
    locBtn.imageView.image = images.lastObject;
    [locBtn.imageView startAnimating];
  }
  [self refreshLocationButtonState:mode];
  self.locationMode = mode;
}


- (void)refreshLocationButtonState:(location::EMyPositionMode)state
{
  dispatch_async(dispatch_get_main_queue(), ^
                 {
                   if (self.locationButton.imageView.isAnimating)
                   {
                     [self refreshLocationButtonState:state];
                   }
                   else
                   {
                     MWMButton * locBtn = self.locationButton;
                     switch (state)
                     {
                       case location::MODE_PENDING_POSITION:
                       {
                         NSArray<UIImage *> * images = animationImages(@"btn_pending", 12);
                         locBtn.imageView.animationDuration = 0.8;
                         locBtn.imageView.animationImages = images;
                         locBtn.imageView.animationRepeatCount = 0;
                         locBtn.imageView.image = images.lastObject;
                         [locBtn.imageView startAnimating];
                         break;
                       }
                       case location::MODE_NOT_FOLLOW:
                       case location::MODE_UNKNOWN_POSITION:
                         locBtn.imageName = @"btn_get_position";
                         break;
                       case location::MODE_FOLLOW:
                         locBtn.imageName = @"btn_follow";
                         break;
                       case location::MODE_ROTATE_AND_FOLLOW:
                         locBtn.imageName = @"btn_follow_and_rotate";
                         break;
                     }
                   }
                 });
}

- (IBAction)locationTouchUpInside
{
  GetFramework().SwitchMyPositionNextMode();
}

#pragma mark - Actions

- (IBAction)zoomTouchDown:(UIButton *)sender
{
  self.zoomSwipeEnabled = YES;
}

- (IBAction)zoomTouchUpInside:(UIButton *)sender
{
  self.zoomSwipeEnabled = NO;
  if ([sender isEqual:self.zoomInButton])
    [self zoomIn];
  else
    [self zoomOut];
}

- (IBAction)zoomTouchUpOutside:(UIButton *)sender
{
  self.zoomSwipeEnabled = NO;
}

- (IBAction)zoomSwipe:(UIPanGestureRecognizer *)sender
{
  if (!self.zoomSwipeEnabled)
    return;
  UIView * const superview = self.zoomView.superview;
  CGFloat const translation = -[sender translationInView:superview].y / superview.bounds.size.height;

  CGFloat const scaleFactor = exp(translation);
  GetFramework().Scale(scaleFactor, false);
}

#pragma mark - Properties

- (BOOL)isZoomEnabled
{
  bool zoomButtonsEnabled = true;
  (void)settings::Get("ZoomButtonsEnabled", zoomButtonsEnabled);
  return zoomButtonsEnabled;
}

- (BOOL)hidden
{
  return self.isZoomEnabled ? self.zoomView.hidden : YES;
}

- (void)setHidden:(BOOL)hidden
{
  if (self.isZoomEnabled)
    [self.zoomView setHidden:hidden animated:YES];
  else
    self.zoomView.hidden = YES;
}

@end
