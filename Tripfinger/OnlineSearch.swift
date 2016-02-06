//
//  OnlineSearch.swift
//  Tripfinger
//
//  Created by Preben Ludviksen on 06/02/16.
//  Copyright © 2016 Preben Ludviksen. All rights reserved.
//

import Foundation
import RealmSwift

class OnlineSearch {
  class func search(fullSearchString: String, gradual: Bool = false, handler: List<SimplePOI> -> ()) {
    
    let escapedString = fullSearchString.stringByAddingPercentEncodingWithAllowedCharacters(.URLPathAllowedCharacterSet())!
    NetworkUtil.getJsonFromUrl(ContentService.baseUrl + "/search/\(escapedString)", success: {
      json in
      
      let searchResults = JsonParserService.parseSearchResults(json)
      
      dispatch_async(dispatch_get_main_queue()) {
        handler(searchResults)
      }
      }, failure: nil)
  }
}