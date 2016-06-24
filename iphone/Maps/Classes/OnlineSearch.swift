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
    
    let failure = {
      handler(List<SimplePOI>())
    }
    
    let url = TripfingerAppDelegate.serverUrl + "/search/\(fullSearchString)"
    let req = NetworkUtil.getJsonFromUrl(url, parameters: parameters, failure: failure) { json in
      let searchResults = JsonParserService.parseSimplePois(json)
      dispatch_async(dispatch_get_main_queue()) {
        handler(searchResults)
      }
    }
    return req
  }
}