//
//  SKMapView+GPSFiles.h
//  SKMaps
//
//  Copyright (c) 2014 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKMapView.h"


@class SKGPSFileElement;

@interface SKMapView (GPSFiles)

/** Renders a GPSFileElement on the map. The color of the rendered polyline can be set in the GPS file using the extensions, in the 'color' field. The color must be in RGBA format. Ex: <extensions><color>FF0000FF</color></extensions>.
 @param element The SKGPSFileElement, result of parsing a GPS file using the SKGPSFilesService class.
 */
- (BOOL)drawGPSFileElement:(SKGPSFileElement *)element;

/** Removes a GPSFileElement from the map.
 @param element The previously drawn SKGPSFileElement, result of parsing a GPS file using the SKGPSFilesService class.
 */
- (BOOL)removeGPSFileElement:(SKGPSFileElement *)element;

/** Fits a previously drawn GPSFileElement on the map, in order to be visible.
 @param element The previously drawn SKGPSFileElement, result of parsing a GPS file using the SKGPSFilesService class.
 */
- (void)fitGPSFileElement:(SKGPSFileElement *)element;
@end
