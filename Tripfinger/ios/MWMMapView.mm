#import <UIKit/UIKit.h>
#import "Framework.h"
#import "MWMMapView.h"

@implementation MWMMapView

+ (instancetype)sharedInstance
{
  static MWMMapView *sharedInstance = nil;
  static dispatch_once_t onceToken;
  if (sharedInstance != nil) {
    [sharedInstance viewFetched];
  }
  dispatch_once(&onceToken, ^{
    sharedInstance = [[MWMMapView alloc] initWithFrame:CGRectZero];
  });
  [(EAGLView *)sharedInstance setPresentAvailable:YES];
  return sharedInstance;
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  [self initializeFramework];
  return self;
}

- (void)initializeFramework
{
  Framework & f = GetFramework();
  
  f.SetMapSelectionListeners([self](place_page::Info const & info) {
    self.onMapObjectSelected(@{
                               @"info": @{
                                   @"title": @(info.GetTitle().c_str()),
                                   @"address": @(info.GetAddress().c_str()),
                                   },
                               });
  }, [self](bool switchFullScreen) {
    self.onMapObjectDeselected(@{@"switchFullScreen": switchFullScreen ? @"true" : @"false"});
  });
  
  f.SetPoiSupplierFunction([self](TripfingerMarkParams& params) {
    return [self poiSupplier:params];
  });
  
  f.SetCoordinateCheckerFunction([self](ms::LatLon latlon) {
    return [self coordinateChecker:latlon];
  });
}

- (vector<TripfingerMark>)poiSupplier:(TripfingerMarkParams &)params
{
  vector<TripfingerMark> tripfingerVector;
  return tripfingerVector;
}

- (bool)coordinateChecker:(ms::LatLon)coord
{
  return NO;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
  
  GetFramework().InvalidateRendering();
}

- (void)viewFetched {
  GetFramework().InvalidateRendering();
}

- (void)onEnterBackground
{
  // Save state and notify about entering background.
  GetFramework().EnterBackground();
}

- (void)onEnterForeground
{
//  if (AppDelegate.theApp.isDaemonMode)
//  return;
  // Notify about entering foreground (should be called on the first launch too).
  GetFramework().EnterForeground();
}

- (void)onGetFocus:(BOOL)isOnFocus
{
  [(EAGLView *)self setPresentAvailable:isOnFocus];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  [self sendTouchType:df::TouchEvent::TOUCH_DOWN withTouches:touches andEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  [self sendTouchType:df::TouchEvent::TOUCH_MOVE withTouches:nil andEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  [self sendTouchType:df::TouchEvent::TOUCH_UP withTouches:touches andEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
  [self sendTouchType:df::TouchEvent::TOUCH_CANCEL withTouches:touches andEvent:event];
}

- (void)sendTouchType:(df::TouchEvent::ETouchType)type withTouches:(NSSet *)touches andEvent:(UIEvent *)event
{
  NSArray * allTouches = [[event allTouches] allObjects];
  if ([allTouches count] < 1)
  return;
  
  CGFloat const scaleFactor = self.contentScaleFactor;
  
  df::TouchEvent e;
  UITouch * touch = [allTouches objectAtIndex:0];
  CGPoint const pt = [touch locationInView:self];
  e.m_type = type;
  e.m_touches[0].m_id = reinterpret_cast<int64_t>(touch);
  e.m_touches[0].m_location = m2::PointD(pt.x * scaleFactor, pt.y * scaleFactor);
  if ([self hasForceTouch])
  e.m_touches[0].m_force = touch.force / touch.maximumPossibleForce;
  if (allTouches.count > 1)
  {
    UITouch * touch = [allTouches objectAtIndex:1];
    CGPoint const pt = [touch locationInView:self];
    e.m_touches[1].m_id = reinterpret_cast<int64_t>(touch);
    e.m_touches[1].m_location = m2::PointD(pt.x * scaleFactor, pt.y * scaleFactor);
    if ([self hasForceTouch])
    e.m_touches[1].m_force = touch.force / touch.maximumPossibleForce;
  }
  
  NSArray * toggledTouches = [touches allObjects];
  if (toggledTouches.count > 0)
  [self checkMaskedPointer:[toggledTouches objectAtIndex:0] withEvent:e];
  
  if (toggledTouches.count > 1)
  [self checkMaskedPointer:[toggledTouches objectAtIndex:1] withEvent:e];
  
  Framework & f = GetFramework();
  f.TouchEvent(e);
}

- (BOOL)hasForceTouch
{
  if (isIOS8)
    return NO;
  return self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable;
}

- (void)checkMaskedPointer:(UITouch *)touch withEvent:(df::TouchEvent &)e
{
  int64_t id = reinterpret_cast<int64_t>(touch);
  int8_t pointerIndex = df::TouchEvent::INVALID_MASKED_POINTER;
  if (e.m_touches[0].m_id == id)
  pointerIndex = 0;
  else if (e.m_touches[1].m_id == id)
  pointerIndex = 1;
  
  if (e.GetFirstMaskedPointer() == df::TouchEvent::INVALID_MASKED_POINTER)
  e.SetFirstMaskedPointer(pointerIndex);
  else
  e.SetSecondMaskedPointer(pointerIndex);
}


@end

@interface MWMMapViewManager : RCTViewManager
@end

@implementation MWMMapViewManager

RCT_EXPORT_MODULE()

RCT_EXPORT_VIEW_PROPERTY(onMapObjectSelected, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onMapObjectDeselected, RCTBubblingEventBlock)

- (UIView *)view
{
  return [MWMMapView sharedInstance];
}

@end
