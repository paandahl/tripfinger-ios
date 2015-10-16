//
//  ContentService.swift
//  Tripfinger
//
//  Created by Preben Ludviksen on 08/10/15.
//  Copyright (c) 2015 Preben Ludviksen. All rights reserved.
//

import Foundation

public typealias ContentLoaded = (guideItem: GuideItem) -> ()

public class ContentService {
    
    let baseUrl = "http://tripfinger-server.appspot.com"
    var session = Session()
    
    public init() {}
    
    public func getGuideTextsForGuideItem(guideItem: GuideItem, handler: (guideTexts: [GuideText]) -> ()) {
        let id = String(guideItem.id!)
        getJsonFromUrl(baseUrl + "/regions/\(id)/guideTexts", success: {
            json in
            
            var guideTexts = self.parseGuideTexts(json!)
            
            dispatch_async(dispatch_get_main_queue()) {
                handler(guideTexts: guideTexts)
            }
            }, failure: nil)
    }
    
    public func getDescriptionForCategory(categoryId: Int, forRegion region: Region, handler: (categoryDescription: GuideText) -> ()) {
        
        let regionId = String(region.id!)
        getJsonFromUrl(baseUrl + "/regions/\(regionId)/guideTextForCategory/\(categoryId)", success: {
            json in
            
            var guideText: GuideText
            if let json = json {
                guideText = self.parseGuideText(json)
            }
            else {
                guideText = GuideText()
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                handler(categoryDescription: guideText)
            }
            }, failure: nil)
    }
    
    public func getRegions(handler: [Region] -> ()) {
        getJsonFromUrl(baseUrl + "/regions", success: {
            json in
            
            var regions = [Region]()
            for regionJson in json!.array! {
                regions.append(self.parseRegion(regionJson, fetchChildren: false))
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                handler(regions)
                
            }
            
        }, failure: nil)
    }

    public func getRegionWithId(regionId: Int, handler: ContentLoaded) {
        getJsonFromUrl(baseUrl + "/regions/\(regionId)", success: {
            json in
            
            let guideItem = self.parseRegion(json!)
            
            dispatch_async(dispatch_get_main_queue()) {
                handler(guideItem: guideItem)

            }}, failure: nil)
    }
    
    public func getGuideTextWithId(guideTextId: Int, handler: GuideItem -> ()) {
        getJsonFromUrl(baseUrl + "/guideTexts/\(guideTextId)", success: {
            json in
            
            let guideText = self.parseGuideText(json!, fetchChildren: true)
            
            dispatch_async(dispatch_get_main_queue()) {
                handler(guideText)
                
            }}, failure: nil)
    }
    
    func getJsonFromUrl(url: String, success: (json: JSON?) -> (), failure: (() -> ())?) {
        let nsUrl = NSURL(string: url)
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithURL(nsUrl!) {
            data, response, error in
            
            if let error = error {
                println("Failure! \(error)")
                if error.code == -999 { return }
            }
                else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    
                    let json = JSON(data: data)
                    success(json: json)
                    return
                }
                else if httpResponse.statusCode == 404 {
                    println("Got 404 from url: \(url)")
                    success(json: nil)
                }
                else {
                    println("Faulire! \(response)")
                }
            }
            
            if let failure = failure {
                dispatch_async(dispatch_get_main_queue(), failure)
            }
        }
        
        dataTask.resume()
        
    }
    
    func parseJSON(data: NSData) -> [String: AnyObject]? {
        var error: NSError?
        if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error) as? [String: AnyObject] {
            return json
        } else if let error = error {
            println("JSON error: \(error)")
        } else {
            println("Unknown JSON error")
        }
        return nil
    }

    func parseGuideItem(json: JSON) -> GuideItem {
        return parseGuideItem(GuideItem(), withJson: json)
    }

    func parseGuideItem(guideItem: GuideItem, withJson json: JSON) -> GuideItem {
        guideItem.name = json["name"].string
        guideItem.id = json["id"].int
        guideItem.description = json["description"].string
        guideItem.category = json["category"].int
        return guideItem
    }

    func parseGuideListing(json: JSON) -> GuideListing {
        return parseGuideItem(GuideListing(), withJson: json) as! GuideListing
    }

    func parseGuideTexts(jsonArray: JSON) -> [GuideText] {
        var guideTexts = [GuideText]()
        for json in jsonArray.array! {
            guideTexts.append(parseGuideText(json))
        }
        return guideTexts
    }
    
    func parseGuideText(json: JSON, fetchChildren: Bool = false) -> GuideText {
        let guideText = parseGuideItem(GuideText(), withJson: json) as! GuideText
        
        if guideText.category == 0 && fetchChildren { // GuideSection
            parseChildren(guideText, withJson: json)
        }
        
        return guideText
    }
    
    func parseRegion(json: JSON, fetchChildren: Bool = true) -> Region {
        let region = parseGuideItem(Region(), withJson: json) as! Region
        
        if (fetchChildren) {
            parseChildren(region, withJson: json)
        }
        return region
    }
    
    func parseChildren(guideItem: GuideItem, withJson json: JSON) {
        println("parsing children")
        var guideSections = [GuideText]()
        var categoryDescriptions = [GuideText]()
        for (id, name) in json["guideSections"].dictionary! {
            let guideSection = GuideText()
            guideSection.id = id.toInt()
            guideSection.name = name.string
            guideSections.append(guideSection)
        }
        
        let categoryDescriptionsDict = json["categoryDescriptions"].dictionary
        for category in Attraction.Category.allValues {
            let categoryDescriptionId = categoryDescriptionsDict![String(category.rawValue)]
            let categoryDescription = GuideText()
            if (categoryDescriptionId != nil) {
                categoryDescription.id = categoryDescriptionId!.int
            }
            else {
                categoryDescription.id = -1
            }
        }
        guideItem.guideSections = guideSections
        guideItem.categoryDescriptions = categoryDescriptions

    }
}