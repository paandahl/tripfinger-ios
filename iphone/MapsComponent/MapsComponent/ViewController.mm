#import "ViewController.h"
#include "std/string.hpp"
#import "EAGLView.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (id)initWithCoder:(NSCoder *)coder
{
  NSLog(@"MapViewController initWithCoder Started");
  self = [super initWithCoder:coder];
  if (self && !AppDelegate.theApp.isDaemonMode)
    [self initialize];
  
  NSLog(@"MapViewController initWithCoder Ended");
  return self;
}

- (void)initialize
{
  Framework & f = GetFramework();
  
  using PoiSupplierFnT = vector<TripfingerMark> (*)(id, SEL, TripfingerMarkParams&);
  SEL poiSupplierSelector = @selector(poiSupplier:);
  PoiSupplierFnT poiSupplierFn = (PoiSupplierFnT)[self methodForSelector:poiSupplierSelector];
  f.SetPoiSupplierFunction(bind(poiSupplierFn, self, poiSupplierSelector, _1));
  
  using CoordinateCheckerFnT = bool (*)(id, SEL, ms::LatLon);
  SEL coordinateCheckerSelector = @selector(coordinateChecker:);
  CoordinateCheckerFnT coordinateCheckerFn = (CoordinateCheckerFnT)[self methodForSelector:coordinateCheckerSelector];
  f.SetCoordinateCheckerFunction(bind(coordinateCheckerFn, self, coordinateCheckerSelector, _1));

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
  
  UIView * v = self.view;
  CGFloat const scaleFactor = v.contentScaleFactor;
  
  df::TouchEvent e;
  UITouch * touch = [allTouches objectAtIndex:0];
  CGPoint const pt = [touch locationInView:v];
  e.m_type = type;
  e.m_touches[0].m_id = reinterpret_cast<int64_t>(touch);
  e.m_touches[0].m_location = m2::PointD(pt.x * scaleFactor, pt.y * scaleFactor);
  if ([self hasForceTouch])
  e.m_touches[0].m_force = touch.force / touch.maximumPossibleForce;
  if (allTouches.count > 1)
  {
    UITouch * touch = [allTouches objectAtIndex:1];
    CGPoint const pt = [touch locationInView:v];
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
  return self.view.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable;
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

- (void)onTerminate
{
  [(EAGLView *)self.view deallocateNative];
}

- (void)onEnterBackground
{
  // Save state and notify about entering background.
  GetFramework().EnterBackground();
}

- (void)onEnterForeground
{
  if (AppDelegate.theApp.isDaemonMode)
    return;
  // Notify about entering foreground (should be called on the first launch too).
  GetFramework().EnterForeground();
}

- (void)onGetFocus:(BOOL)isOnFocus
{
  [(EAGLView *)self.view setPresentAvailable:isOnFocus];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  if (AppDelegate.theApp.isDaemonMode)
    return;
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
  
  GetFramework().InvalidateRendering();
}

@end
