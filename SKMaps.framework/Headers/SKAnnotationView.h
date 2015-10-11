//
//  SKAnnotationView.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/** Can be used to set a custom view as a map annotation.
 */
@interface SKAnnotationView : NSObject

/** The view to be rendered as an annotation.
 */
@property(nonatomic, readonly, strong) UIView *view;

/** A unique identifier for the view which is used for caching.
 */
@property(nonatomic, readonly, strong) NSString *reuseIdentifier;

/** Initializes an SKAnnotationView object with the given parameters.
 @param view A view object containing the visual representation of the SKAnnotationView.
 @param reuseIdentifier A string identifying the SKAnnotationView object to be reused.
 @return A newly initialized SKAnnotationView instance.
 */
- (id)initWithView:(UIView *)view reuseIdentifier:(NSString *)reuseIdentifier;

@end
