//
//  SKMapStyle.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.

#import <Foundation/Foundation.h>
#import "SKDefinitions.h"

/** SKMapViewStyle stores information about the style of the map.
 */
@interface SKMapViewStyle : NSObject

/** The ID used to identify a style. Should be used for alternative styles. For the main style, 0 is set by default.
 */
@property(nonatomic, assign) int styleID;

/** The name of the desired map style resources folder, located in SKMaps.bundle/MapResources . The default is "DayStyle".
 */
@property(nonatomic, strong) NSString *resourcesFolderName;

/** The name of the map style JSON, located in the resourcesFolderName. The default is "daystyle.json".
 */
@property(nonatomic, strong) NSString *styleFileName;

#pragma mark Advanced

/** The absolute path to the map style resource folder. The default is SKMaps.bundle/MapResources, located in the main bundle. Should be changed only for downloaded styles.
 */
@property(nonatomic, strong) NSString *resourcesPath;

/** A newly initialized SKMapViewStyle.
 */
+ (instancetype)mapViewStyle;

@end
