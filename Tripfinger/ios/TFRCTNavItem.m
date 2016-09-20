/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "TFRCTNavItem.h"
#import "RCTConvert.h"
#import "TFRCTAction.h"

@implementation TFRCTNavItem

@synthesize delegate = _delegate;
@synthesize backButtonItem = _backButtonItem;
@synthesize leftButtonItem = _leftButtonItem;
@synthesize rightButtonItem = _rightButtonItem;

- (UIImageView *)titleImageView
{
  if (_titleImage) {
    return [[UIImageView alloc] initWithImage:_titleImage];
  } else {
    return nil;
  }
}

- (void)setBackButtonTitle:(NSString *)backButtonTitle
{
  _backButtonTitle = backButtonTitle;
  _backButtonItem = nil;
}

- (void)setBackButtonIcon:(UIImage *)backButtonIcon
{
  _backButtonIcon = backButtonIcon;
  _backButtonItem = nil;
}

- (UIBarButtonItem *)backButtonItem
{
  if (!_backButtonItem) {
    if (_backButtonIcon) {
      _backButtonItem = [[UIBarButtonItem alloc] initWithImage:_backButtonIcon
                                                         style:UIBarButtonItemStylePlain
                                                        target:nil
                                                        action:nil];
    } else if (_backButtonTitle.length) {
      _backButtonItem = [[UIBarButtonItem alloc] initWithTitle:_backButtonTitle
                                                         style:UIBarButtonItemStylePlain
                                                        target:nil
                                                        action:nil];
    } else {
      _backButtonItem = nil;
    }
  }
  return _backButtonItem;
}

- (void)setLeftButtonTitle:(NSString *)leftButtonTitle
{
  _leftButtonTitle = leftButtonTitle;
  _leftButtonItem = nil;
}

- (void)setLeftButtonIcon:(UIImage *)leftButtonIcon
{
  _leftButtonIcon = leftButtonIcon;
  _leftButtonItem = nil;
}

- (UIBarButtonItem *)leftButtonItem
{
  if (!_leftButtonItem) {
    if (_leftButtonIcon) {
      _leftButtonItem =
      [[UIBarButtonItem alloc] initWithImage:_leftButtonIcon
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(handleLeftButtonPress)];
      
    } else if (_leftButtonTitle.length) {
      _leftButtonItem =
      [[UIBarButtonItem alloc] initWithTitle:_leftButtonTitle
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(handleLeftButtonPress)];
    } else {
      _leftButtonItem = nil;
    }
  }
  return _leftButtonItem;
}

- (void)handleLeftButtonPress
{
  if (_onLeftButtonPress) {
    _onLeftButtonPress(nil);
  }
}

- (void)setRightButtonTitle:(NSString *)rightButtonTitle
{
  _rightButtonTitle = rightButtonTitle;
  _rightButtonItem = nil;
}

- (void)setRightButtonIcon:(UIImage *)rightButtonIcon
{
  _rightButtonIcon = rightButtonIcon;
  _rightButtonItem = nil;
}

- (NSArray<UIBarButtonItem*> *)rightButtonItems
{
  NSMutableArray<UIBarButtonItem*>* items = [[NSMutableArray<UIBarButtonItem*> alloc] init];
  if (_rightButtonActions) {
    for(TFRCTAction *action in self.rightButtonActions) {
      UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithImage:action.icon
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(handleRightButtonPress:)];
      item.accessibilityValue = action.action;
      [items insertObject:item atIndex:0];
    }
  }
  return items;
}


- (UIBarButtonItem *)rightButtonItem
{
  if (!_rightButtonItem) {
    if (_rightButtonIcon) {
      _rightButtonItem =
      [[UIBarButtonItem alloc] initWithImage:_rightButtonIcon
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(handleRightButtonPress:)];
      
    } else if (_rightButtonTitle.length) {
      _rightButtonItem =
      [[UIBarButtonItem alloc] initWithTitle:_rightButtonTitle
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(handleRightButtonPress:)];
    } else {
      _rightButtonItem = nil;
    }
  }
  return _rightButtonItem;
}

- (void)handleRightButtonPress:(UIBarButtonItem*)sender
{
  if (_onRightButtonPress) {
    _onRightButtonPress(@{@"action": sender.accessibilityValue});
  }
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden
{
  if (navigationBarHidden != _navigationBarHidden) {
    _navigationBarHidden = navigationBarHidden;
    [self.delegate navigationBarHiddenDidChange:navigationBarHidden];
  }
}

- (void)setRightButtonActions:(NSArray*)actions
{
  NSMutableArray * actionsArray = [NSMutableArray new];
  for(NSDictionary *actionDict in actions) {
    TFRCTAction * action = [[TFRCTAction alloc] init];
    action.action = actionDict[@"action"];
    action.icon = [RCTConvert UIImage:actionDict[@"res"]];
    [actionsArray addObject:action];
  }
  _rightButtonActions = actionsArray;
}


@end
