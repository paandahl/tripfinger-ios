//UIImage+initWithColor.h
//
#import <UIKit/UIKit.h>

@interface UIImage (initWithColor)

//programmatically create an UIImage with 1 pixel of a given color
+ (UIImage *)imageWithColor:(UIColor *)color;

//implement additional methods here to create images with gradients etc.
//[..]

@end

//UIImage+initWithColor.m
//
#import "UIImage+initWithColor.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIImage (initWithColor)

+ (UIImage *)imageWithColor:(UIColor *)color
{
  CGRect rect = CGRectMake(0, 0, 1, 1);
  
  // create a 1 by 1 pixel context
  UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
  [color setFill];
  UIRectFill(rect);
  
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return image;
}

@end