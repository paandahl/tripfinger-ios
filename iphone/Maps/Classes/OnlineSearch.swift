import Foundation
import RealmSwift
import Alamofire

class OnlineSearch {
  class func search(fullSearchString: String, handler: List<SimplePOI> -> ()) -> Request {
    
    var parameters = [String: String]()
    if TripfingerAppDelegate.mode != TripfingerAppDelegate.AppMode.RELEASE {
      parameters["fetchType"] = "STAGED_OR_PUBLISHED"
    } else {
      parameters["fetchType"] = "ONLY_PUBLISHED"
    }
    
    let req = NetworkUtil.getJsonFromUrl(TripfingerAppDelegate.serverUrl + "/search/\(fullSearchString)", parameters: parameters, success: {
      json in
      
      let searchResults = JsonParserService.parseSimplePois(json)
      
      dispatch_async(dispatch_get_main_queue()) {
        handler(searchResults)
      }
      }, failure: {
        handler(List<SimplePOI>())
    })
    
    return req
  }
}