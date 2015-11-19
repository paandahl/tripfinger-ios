//
//  OfflineService.swift
//  Tripfinger
//
//  Created by Preben Ludviksen on 18/11/15.
//  Copyright © 2015 Preben Ludviksen. All rights reserved.
//

import Foundation
import RealmSwift

class OfflineService {
  
  static let realm = try! Realm()
  
  class func getRegionWithId(regionId: String) -> Region? {
    let regions = realm.objects(Region)

    for region in regions {
      if region.listing.item.id == regionId {
        region.offline = true
        return region
      }
    }
    return nil
  }
  
  class func getGuideTextWithId(region: Region, guideTextId: String) -> GuideText {
    let guideTexts = realm.objects(GuideText).filter("item.id = '\(guideTextId)'")
    return guideTexts[0]
  }
}