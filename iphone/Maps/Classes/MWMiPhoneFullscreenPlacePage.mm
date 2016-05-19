#import "Common.h"
#import "MapViewController.h"
#import "MWMBasePlacePageView.h"
#import "MWMiPhoneFullscreenPlacePage.h"
#import "MWMMapViewControlsManager.h"
#import "MWMPlacePage+Animation.h"
#import "MWMPlacePageActionBar.h"
#import "MWMPlacePageEntity.h"
#import "MWMPlacePageNavigationBar.h"
#import "MWMPlacePageViewManager.h"
#import "MWMSpringAnimation.h"
#import "UIImageView+Coloring.h"

#include "Framework.h"

extern CGFloat const kBottomPlacePageOffset;
extern CGFloat const kLabelsBetweenOffset;

@interface MWMiPhoneFullscreenPlacePage ()
@end

@implementation MWMiPhoneFullscreenPlacePage

- (void)configure
{
  [super configure];
  self.basePlacePageView.featureTable.scrollEnabled = NO;
  CGSize const size = UIScreen.mainScreen.bounds.size;
  CGFloat const width = MIN(size.width, size.height);
  CGFloat const height = MAX(size.width, size.height);
  UIView * ppv = self.extendedPlacePageView;
  ppv.frame = CGRectMake(0., 0, width, 8 * height);
  self.actionBar.width = width;
  self.actionBar.center = {width / 2, height + self.actionBar.height / 2};
  [self.manager addSubviews:@[ppv, self.actionBar] withNavigationController:nil];
  [UIView animateWithDuration:kDefaultAnimationDuration delay:0. options:UIViewAnimationOptionCurveEaseOut animations:^
   {
     self.actionBar.center = {width / 2, height - self.actionBar.height / 2};
   }
                   completion:nil];
  self.panRecognizer.enabled = NO;
}

- (void)dismiss
{
  [MWMPlacePageNavigationBar remove];
  [super dismiss];
}

- (void)addBookmark
{
  [super addBookmark];
}

- (void)removeBookmark
{
  [super removeBookmark];
}

- (void)reloadBookmark
{
  [super reloadBookmark];
  [self refresh];
}

- (void)updateMyPositionStatus:(NSString *)status
{
  [super updateMyPositionStatus:status];
  [self refresh];
}


- (CGFloat)topY
{
  MWMBasePlacePageView * basePPV = self.basePlacePageView;
  CGSize const size = UIScreen.mainScreen.bounds.size;
  CGFloat const height = MAX(size.width, size.height);
  CGFloat const tableViewHeight = basePPV.featureTable.height;
  return 0.0;
}

- (CGFloat)topPlacePageHeight
{
  MWMBasePlacePageView * basePPV = self.basePlacePageView;
  CGFloat const anchorHeight = self.anchorImageView.height;
  CGFloat const actionBarHeight = self.actionBar.height;
  BOOL const typeIsNotEmpty = basePPV.typeLabel.text.length > 0;
  BOOL const addressIsNotEmpty = basePPV.addressLabel.text.length > 0;
  CGFloat const titleHeight = basePPV.titleLabel.height + (typeIsNotEmpty ? kLabelsBetweenOffset : 0);
  CGFloat const typeHeight = typeIsNotEmpty ? basePPV.typeLabel.height + (addressIsNotEmpty ? kLabelsBetweenOffset : 0) : 0;
  CGFloat const addressHeight = addressIsNotEmpty ? basePPV.addressLabel.height : 0;
  return anchorHeight + titleHeight + typeHeight + addressHeight + kBottomPlacePageOffset + actionBarHeight;
}

#pragma mark - Actions

- (IBAction)didTap:(UITapGestureRecognizer *)sender
{
  [super didTap:sender];
  sender.cancelsTouchesInView = NO;
}

- (void)willStartEditingBookmarkTitle
{
  [super willStartEditingBookmarkTitle];
//  if (self.isHover)
//    self.state = MWMiPhonePortraitPlacePageStateHover;
//  else
//    self.state = MWMiPhonePortraitPlacePageStateOpen;
}

- (void)willFinishEditingBookmarkTitle:(NSString *)title
{
  [super willFinishEditingBookmarkTitle:title];
  [self refresh];
}

@end
