//
//  SKSearchResultParent.h
//  ForeverMapNGX
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKDefinitions.h"

/** SKSearchResultParent provides additional information about the the ascendants of an SKSearchResult object. Instances of this class are used as objects in the parentList property of the SKSearchResult class.
 */
@interface SKSearchResultParent : NSObject

/** The index of the parent. Each SKSearchResultParent object has a unique index.
 */
@property(nonatomic, assign) int parentIndex;

/** The type of the parent (country, state, city, etc.). For further details please check the SKSearchResultType enum.
 */
@property(nonatomic, assign) SKSearchResultType type;

/** The name of the parent. For example: for an SKSearchResultParent object with type country, this property could be Germany.
 */
@property(nonatomic, strong) NSString *name;

/** Creates a SKSearchResultParent, initialized with the values passed as parameters.
 @param index The index of the parent.
 @param type The type of the parent (Country, state, city, etc.).
 @param name The name of the parent.
 @return A newly initialized SKSearchResultParent with the values passed as parameters.
 */
+ (instancetype)searchResultParentWithIndex:(int)index type:(int)type name:(NSString *)name;

@end
