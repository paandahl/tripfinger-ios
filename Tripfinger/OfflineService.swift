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
  
  class func saveRegion(region: Region) throws {
    
    let existing = getRegionWithId(region.getId())
    if existing != nil {
      throw Error.RuntimeError("Reagion with id \(region.getId()) already exists in db.")
    }
    
    // Add to the Realm inside a transaction
    try! realm.write {
      realm.add(region)
    }
  }
  
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
  
  class func deleteRegionWithId(regionId: String) {
    try! realm.write {
      let region = getRegionWithId(regionId)
      realm.delete(region!)
    }
  }
  
  class func getRegionsWithParent(parentId: String) -> Results<Region> {
    return realm.objects(Region).filter("listing.item.parent = '\(parentId)'")
  }
  
  class func getGuideTextWithId(region: Region, guideTextId: String) -> GuideText {
    let guideTexts = realm.objects(GuideText).filter("item.id = '\(guideTextId)'")
    return guideTexts[0]
  }
}