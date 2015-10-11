//
//  SKVisualAdviceConfiguration.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIColor.h>
#import "SKDefinitions.h"

/** The SKVisualAdviceConfiguration is used to store the colors of a generated visual advice image
 */
@interface SKVisualAdviceConfiguration : NSObject

/** The code of the country.
 */
@property(nonatomic, strong) NSString *countryCode;

/** The type of the street.
 */
@property(nonatomic, assign) SKStreetType streetType;

/** The color of the allowed street.
 */
@property(nonatomic, strong) UIColor *allowedStreetColor;

/** The color of the forbidden street.
 */
@property(nonatomic, strong) UIColor *forbiddenStreetColor;

/** The color of the route's street.
 */
@property(nonatomic, strong) UIColor *routeStreetColor;

/** The background color of the visual advice.
 */
@property(nonatomic, strong) UIColor *backgroundColor;

/** A newly initialized SKVisualAdviceConfiguration.
 */
+ (instancetype)visualAdviceColor;

@end
