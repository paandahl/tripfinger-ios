//
//  Session.swift
//  Tripfinger
//
//  Created by Preben Ludviksen on 08/10/15.
//  Copyright (c) 2015 Preben Ludviksen. All rights reserved.
//

import Foundation
import RealmSwift

class Session {
  
  init() {}

  var currentItemId: String!
  var currentRegion: Region?
  var currentSection: GuideText?
  var currentCategory = Attraction.Category.EXPLORE_CITY

  var currentAttractions = List<Attraction>()
  var attractionsFromCategory: Attraction.Category!
  var attractionsFromRegion: Region!
  
  func loadRegionWithID(regionId: String, handler: () -> ()) {
    
    ContentService.getRegionWithId(regionId) {
      region in
      
      self.currentRegion = region
      handler()
    }
  }
  
  
  func loadAttractions(handler: (loaded: Bool) -> ()) {
    
    if currentRegion == nil {
      currentAttractions = List<Attraction>()
      handler(loaded: false)
      return
    }
    
    if (attractionsFromCategory == nil || attractionsFromCategory != currentCategory || attractionsFromRegion != currentRegion) {
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
      attractionsFromRegion = currentRegion
    }
    else {
      handler(loaded: false)
    }
  }
}