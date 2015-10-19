//
//  MultiStepSearchViewController.m
//  FrameworkIOSDemo
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "MultiStepSearch.h"

@implementation MultiStepSearchViewController

-(void)fireSearch
{
    if (self.multiStepObject.parentIndex == 0) {
        self.multiStepObject.parentIndex = -1;        
    }
    [[SKSearchService sharedInstance]startMultiStepSearchWithSettings:self.multiStepObject];

}

@end
