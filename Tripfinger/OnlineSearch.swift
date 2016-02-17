import Foundation
import RealmSwift

class OnlineSearch {
  class func search(fullSearchString: String, gradual: Bool = false, handler: List<SimplePOI> -> ()) {
    
    var parameters = [String: String]()
    if AppDelegate.beta {
      parameters["onlyPublished"] = "false"
    }
    
    let escapedString = fullSearchString.stringByAddingPercentEncodingWithAllowedCharacters(.URLPathAllowedCharacterSet())!
    NetworkUtil.getJsonFromUrl(ContentService.baseUrl + "/search/\(escapedString)", parameters: parameters, success: {
      json in
      
      let searchResults = JsonParserService.parseSearchResults(json)
      
      dispatch_async(dispatch_get_main_queue()) {
        handler(searchResults)
      }
      }, failure: nil)
  }
}