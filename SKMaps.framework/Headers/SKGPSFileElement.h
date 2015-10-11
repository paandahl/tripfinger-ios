//
//  SKGPSFileElement.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, SKGPSFileElementType)
{
    SKGPSFileElementGPXRoot,
    SKGPSFileElementGPXRoute,
    SKGPSFileElementGPXRoutePoint,
    SKGPSFileElementGPXTrack,
    SKGPSFileElementGPXTrackSegment,
    SKGPSFileElementGPXTrackPoint,
    SKGPSFileElementGPXWaypoint
};

/** SKGPSFileElement stores information about a generic GPS file element, result of parsing the GPS file. Shouldn't be explicitely allocated.
 */
@interface SKGPSFileElement : NSObject

/** Internally generated identifier for the element.
 */
@property(nonatomic, assign) NSInteger identifier;

/** Internally generated identifier for the GPS file.
 */
@property(nonatomic, assign) NSInteger fileIdentifier;

/** The type of the element.
 */
@property(nonatomic, assign) SKGPSFileElementType type;

/** The name of the element, that it's found in the GPS file.
 */
@property(nonatomic, strong) NSString *name;

/** The extensions of the element, that are found in the GPS file.
 */
@property(nonatomic, strong) NSString *extensions;

@end
