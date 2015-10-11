//
//  ContentService.swift
//  Tripfinger
//
//  Created by Preben Ludviksen on 08/10/15.
//  Copyright (c) 2015 Preben Ludviksen. All rights reserved.
//

import Foundation

class ContentService {
    
    let baseUrl = "http://tripfinger-server.appspot.com"
    var session = Session()
    
    func getCurrentLocationData(updateUI: (location: GuideItem, guideTexts: [GuideText], guideLocations: [GuideLocation]) -> ()) {
        runJsonGetUrl(baseUrl + "/city", success: {
            json in
        
            let guideItem = GuideItem()
            guideItem.name = json.array![0]["name"].string
            guideItem.description = json.array![0]["description"].string
            
            dispatch_async(dispatch_get_main_queue()) {
                updateUI(location: guideItem, guideTexts: [GuideText](), guideLocations: [GuideLocation]())
            }
            
            }, failure: nil)
    }
    
    func runJsonGetUrl(url: String, success: (json: JSON) -> (), failure: (() -> ())?) {
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

}