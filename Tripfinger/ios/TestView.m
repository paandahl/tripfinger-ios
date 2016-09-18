#import <UIKit/UIKit.h>
#import "RCTViewManager.h"

@interface TestView : UIView
@end

@implementation TestView {
  UILabel * label;
}

- (void)baseInit {
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self baseInit];
  }
  return self;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  NSLog(@"layoutSubviews");
  NSLog(@"%@", NSStringFromCGRect(self.bounds));
  label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
  label.text = @"Fuck off";
  label.backgroundColor = [UIColor yellowColor];
  [self addSubview:label];
}

@end

@interface RCTTestViewManager : RCTViewManager
@end

@implementation RCTTestViewManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
  return [[TestView alloc] initWithFrame:CGRectZero];
}

@end
