//
//  Session.swift
//  Tripfinger
//
//  Created by Preben Ludviksen on 08/10/15.
//  Copyright (c) 2015 Preben Ludviksen. All rights reserved.
//

import Foundation
 class Session {
    
    init() {}
    
    var currentRegion: Region?
    var currentCategory = Attraction.Category.EXPLORE_CITY
    var attractionsFromCategory: Attraction.Category!
    var currentAttractions = [Attraction]()
    
    func loadBrusselsAsCurrentRegionIfEmpty(handler: () -> ()) {
        if currentRegion == nil {
            loadRegionWithID("region-brussels", handler: handler)
        }
        else {
            handler()
        }
    }
    
    func loadRegionWithID(regionId: String, handler: () -> ()) {
        
        ContentService.getRegionWithId(regionId) {
            region in
            
            self.currentRegion = region
            handler()
        }
    }

    
    func loadAttractions(handler: (loaded: Bool) -> ()) {
        
        if (attractionsFromCategory == nil || attractionsFromCategory != currentCategory) {
            if currentCategory != Attraction.Category.ALL {
                ContentService.getAttractionsForRegion(self.currentRegion!, withCategory: currentCategory) {
                    attractions in
                    
                    self.currentAttractions = attractions
                    handler(loaded: true)
                }
            }
            else {
                ContentService.getAttractionsForRegion(self.currentRegion!) {
                    attractions in
                    
                    self.currentAttractions = attractions
                    handler(loaded: true)
                }
            }
            attractionsFromCategory = currentCategory
        }
        else {
            handler(loaded: false)
        }
    }
}