import Foundation
import RealmSwift
import Alamofire

class OnlineSearch {
  class func search(fullSearchString: String, handler: List<SimplePOI> -> ()) -> Request {
    
    var parameters = [String: String]()
    if AppDelegate.mode != AppDelegate.AppMode.RELEASE {
      parameters["onlyPublished"] = "false"
    }
    
    let escapedString = fullSearchString.stringByAddingPercentEncodingWithAllowedCharacters(.URLPathAllowedCharacterSet())!
    let req = NetworkUtil.getJsonFromUrl(ContentService.baseUrl + "/search/\(escapedString)", parameters: parameters, success: {
      json in
      
      let searchResults = JsonParserService.parseSearchResults(json)
      
      dispatch_async(dispatch_get_main_queue()) {
        handler(searchResults)
      }
      }, failure: nil)
    
    return req
  }
}