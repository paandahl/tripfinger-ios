//
//  SKVersionInformation.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>

/** SKVersionInformation stores information about a map version supported by the framework.
 */
@interface SKVersionInformation : NSObject

/** The version string. An identifier represented by the date the map was created.
 */
@property(nonatomic, strong) NSString *version;

/** The router version.
 */
@property(nonatomic, strong) NSString *routerVersion;

/** The name browser version.
 */
@property(nonatomic, strong) NSString *nameBrowserVersion;

/** A newly initialized SKVersionInformation.
 */
+ (instancetype)versionInformation;

@end
