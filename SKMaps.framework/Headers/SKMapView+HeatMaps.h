//
//  SKMapView+HeatMaps.h
//  SKMaps
//
//  Copyright (c) 2014 Skobbler. All rights reserved.
//

#import "SKMapView.h"

/**
 */
@interface SKMapView (HeatMaps)

/** Renders a heat map based on a list of POI categories.
 @param poiTypes An array of NSNumbers representing SKPOICategory elements for the HeatMap.
 */
- (void)showHeatMapWithPOIType:(NSArray *)poiTypes;

/** Clears the previously added HeatMap.
 */
- (void)clearHeatMap;

@end
