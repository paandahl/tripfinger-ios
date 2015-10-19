//
//  MultiStepSearchViewController.h
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKMaps/SKMaps.h"

@interface MultiStepSearchViewController : NSObject

@property(nonatomic,strong) SKMultiStepSearchSettings *multiStepObject;

-(void)fireSearch;

@end
