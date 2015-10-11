//
//  SKMapPackage.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>

/**SKMapPackage class provides information about an installed map package.
 */

@interface SKMapPackage : NSObject

/** The name of the map package.
 */
@property(nonatomic, strong) NSString *name;

/** The version of the map package.
 */
@property(nonatomic, strong) NSString *version;

/** The size of the map package, in bytes.
 */
@property(nonatomic, assign) long long size;

/**A newly initialized SKMapPackage.
 */
+ (instancetype)mapPackage;

@end
