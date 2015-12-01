//
//  SKOverlay.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIColor;

/** Stores information about an overlay.
 */
@interface SKOverlay : NSObject

/** A unique identifier for the overlay.
 */
@property(nonatomic, assign) int identifier;

/** The inner/outer color of the polygon depending on the value of the isMask property.
 */
@property(nonatomic, strong) UIColor *fillColor;

/** The border color of the polygon. Set to nil for no border.
 */
@property(nonatomic, strong) UIColor *strokeColor;

/** The number of pixels of a dotted line. Set to 0 for solid boder.
 */
@property(nonatomic, assign) int borderDotsSize;

/** The number of pixels between the dotted lines.
 */
@property(nonatomic, assign) int borderDotsSpacingSize;

@end
