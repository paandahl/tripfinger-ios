/**
* Copyright (c) 2015-present, Facebook, Inc.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

#import <UIKit/UIKit.h>

#import "RCTViewControllerProtocol.h"

@class TFRCTNavItem;
@class TFRCTWrapperViewController;

@protocol TFRCTWrapperViewControllerNavigationListener <NSObject>

- (void)wrapperViewController:(TFRCTWrapperViewController *)wrapperViewController
didMoveToNavigationController:(UINavigationController *)navigationController;

@end

@interface TFRCTWrapperViewController : UIViewController <RCTViewControllerProtocol>

- (instancetype)initWithContentView:(UIView *)contentView NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithNavItem:(TFRCTNavItem *)navItem;
- (void)navigationBarHiddenDidChange:(BOOL)navigationBarHidden;

@property (nonatomic, weak) id<TFRCTWrapperViewControllerNavigationListener> navigationListener;
@property (nonatomic, strong) TFRCTNavItem *navItem;

@end
