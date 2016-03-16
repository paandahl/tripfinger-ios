import Foundation
import RealmSwift
import Alamofire

typealias ContentLoaded = (guideItem: GuideItem) -> ()

class ContentService {
  
  init() {}
  
  class func getPois(bottomLeft: CLLocationCoordinate2D, topRight: CLLocationCoordinate2D, zoomLevel: Int, category: Listing.Category, handler: List<SimplePOI> -> ()) -> Request {
    
    let bounds = "\(bottomLeft.latitude),\(bottomLeft.longitude),\(topRight.latitude),\(topRight.longitude)"
    let parameters = ["categoryId": "\(category.rawValue)"]
    return NetworkUtil.getJsonFromUrl(AppDelegate.serverUrl + "/search_by_bounds/\(bounds)/\(zoomLevel)", parameters: parameters, success: {
      json in
      
      let searchResults = JsonParserService.parseSimplePois(json)
      
      dispatch_async(dispatch_get_main_queue()) {
        for searchResult in searchResults {
          if searchResult.isRealListing() {
            if let guideListingNotes = DatabaseService.getListingNotes(searchResult.listingId) {
              searchResult.notes = guideListingNotes
            }
          }
        }
        handler(searchResults)
      }
      }, failure: nil)
  }
  
  
  class func getCountries(handler: [Region] -> ()) {
    let parameters = ["onlyPublished": "false"]
    NetworkUtil.getJsonFromUrl(AppDelegate.serverUrl + "/countries", parameters: parameters, success: {
      json in
      
      let regions = JsonParserService.parseRegions(json)
      
      dispatch_async(dispatch_get_main_queue()) {
        handler(regions)
      }
      
      }, failure: nil)
  }
  
  class func getGuideTextsForGuideItem(guideItem: GuideItem, handler: (guideTexts: [GuideText]) -> ()) {
    let id = String(guideItem.id!)
    NetworkUtil.getJsonFromUrl(AppDelegate.serverUrl + "/regions/\(id)/guideTexts", success: {
      json in
      
      let guideTexts = JsonParserService.parseGuideTexts(json)
      
      dispatch_async(dispatch_get_main_queue()) {
        handler(guideTexts: guideTexts)
      }
      }, failure: nil)
  }
  
  class func getFullRegionTree(regionId: String, handler: (region: Region) -> ()) {
    NetworkUtil.getJsonFromUrl(AppDelegate.serverUrl + "/regions/\(regionId)/full", success: {
      json in
      
      let region = JsonParserService.parseRegionTreeFromJson(json)
      
      dispatch_async(dispatch_get_main_queue()) {
        handler(region: region)
      }
      }, failure: nil)
  }
  
  class func getRegions(handler: [Region] -> ()) {
    NetworkUtil.getJsonFromUrl(AppDelegate.serverUrl + "/regions", success: {
      json in
      
      var regions = [Region]()
      for regionJson in json.array! {
        regions.append(JsonParserService.parseRegion(regionJson, fetchChildren: false))
      }
      
      dispatch_async(dispatch_get_main_queue()) {
        handler(regions)
        
      }
      
      }, failure: nil)
  }
  
  class func getRegionFromListing(listing: GuideListing, handler: (Region) -> ()) {
    var url: String!
    switch listing.item.category {
    case Region.Category.NEIGHBOURHOOD.rawValue:
      if let region = DatabaseService.getNeighbourhood(listing.country, cityName: listing.city, hoodName: listing.item.name) {
        handler(region)
        return
      }
      url = AppDelegate.serverUrl + "/neighbourhoods/\(listing.country)/\(listing.city)/\(listing.item.name)"
    case Region.Category.CITY.rawValue:
      fallthrough
    case Region.Category.SUB_REGION.rawValue:
      if let region = DatabaseService.getSubRegionOrCity(listing.country, itemName: listing.item.name) {
        handler(region)
        return
      }
      url = AppDelegate.serverUrl + "/subRegionOrCity/\(listing.country)/\(listing.item.name)"
    case Region.Category.COUNTRY.rawValue:
      if let region = DatabaseService.getCountry(listing.item.name) {
        handler(region)
        return
      }
      url = AppDelegate.serverUrl + "/countries/\(listing.item.name)"
    default:
      url = AppDelegate.serverUrl + "/continents/\(listing.item.name)"
    }
    
    var parameters = [String: String]()
    if AppDelegate.mode != AppDelegate.AppMode.RELEASE {
      parameters["onlyPublished"] = "false"
    }
    
    NetworkUtil.getJsonFromUrl(url, parameters: parameters, success: {
      json in
      
      let region = JsonParserService.parseRegion(json)
      
      dispatch_async(dispatch_get_main_queue()) {
        handler(region)
        
      }})
  }
  
  class func getRegionWithId(regionId: String, failure: (() -> ())? = nil, handler: Region -> ()) {
    if let region = DatabaseService.getRegionWithId(regionId) {
      handler(region)
      return
    }
    NetworkUtil.getJsonFromUrl(AppDelegate.serverUrl + "/regions/\(regionId)", success: {
      json in
      
      let region = JsonParserService.parseRegion(json)
      
      dispatch_async(dispatch_get_main_queue()) {
        handler(region)
        
      }}, failure: {
        if let failure = failure {
          failure()
        } else {
          fatalError("Fetching region with id \(regionId) failed.")
        }
    })
  }
  
  class func getGuideTextWithId(region: Region, guideTextId: String, handler: GuideText -> ()) {
    print("getting guidetext")
    if region.item().offline {
      handler(DatabaseService.getGuideTextWithId(region, guideTextId: guideTextId))
      return
    }
    print("region not offline")
    NetworkUtil.getJsonFromUrl(AppDelegate.serverUrl + "/guideTexts/\(guideTextId)", success: {
      json in
      
      let guideText = JsonParserService.parseGuideText(json, fetchChildren: true)
      
      dispatch_async(dispatch_get_main_queue()) {
        handler(guideText)
        
      }})
  }
  
  class func getListingWithId(attractionId: String, handler: Listing -> ()) {
    if let attraction = DatabaseService.getListingWithId(attractionId) {
      handler(attraction)
      return
    }
    NetworkUtil.getJsonFromUrl(AppDelegate.serverUrl + "/attractions/\(attractionId)", success: {
      json in
      
      let attraction = JsonParserService.parseListing(json)
      
      dispatch_async(dispatch_get_main_queue()) {
        handler(attraction)
      }
    })
    
  }
    
  class func getCascadingListingsForRegion(region: Region?, withCategory category: Listing.Category? = nil, handler: List<Listing> -> ()) {
    
    if !NetworkUtil.connectedToNetwork() || (region != nil && region!.item().offline) {
      print("fetching offline attractions")
      let attractions = DatabaseService.getCascadingListingsForRegion(region, category: category)
      handler(attractions)
      
    } else {
      
      var url: String
      var parameters = [String: String]()
      if let region = region {
        
        switch region.item().category {
        case Region.Category.CONTINENT.rawValue:
          fallthrough
        case Region.Category.COUNTRY.rawValue:
          fallthrough
        case Region.Category.SUB_REGION.rawValue:
          fallthrough
        case Region.Category.CITY.rawValue:
          parameters["cascade"] = "true"
        case Region.Category.NEIGHBOURHOOD.rawValue:
          parameters["cascade"] = "false"
        default:
          try! { throw Error.RuntimeError("Region category not recognized: \(region.item().category)") }()
        }
        url = AppDelegate.serverUrl + "/regions/\(region.listing.item.id)/attractions"
        
      } else {
        url = AppDelegate.serverUrl + "/attractions"
      }
      
      if let category = category {
        parameters["categoryId"] = String(category.rawValue)
      }
      
      if AppDelegate.mode != AppDelegate.AppMode.RELEASE {
        parameters["onlyPublished"] = "false"
      }
      
      NetworkUtil.getJsonFromUrl(url, parameters: parameters, success: {
        json in
        
        dispatch_async(dispatch_get_main_queue()) {
          let listings = JsonParserService.parseListings(json)
          for listing in listings {
            if let notes = DatabaseService.getListingNotes(listing.item().id) {
              listing.listing.notes = notes
            }
          }
          
          handler(listings)
          
        }}, failure: nil)
    }
  }
  
  class func getJsonFromPost(var url: String, body: String, appendPass: Bool = true, success: (json: JSON) -> (), failure: (() -> ())? = nil) {
    
    print("Fetching POST URL: \(url)")
    
    if appendPass {
      url += "?pass=plJR86!!"
    }
    let nsUrl = NSURL(string: url)!
    let request = NSMutableURLRequest(URL: nsUrl)
    request.HTTPMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
    
    Alamofire.request(request).validate(statusCode: 200..<300).responseJSON {
      response in
      
      if response.result.isSuccess {
        let json = JSON(data: response.data!)
        success(json: json)
      }
      else {
        print("Failure fetching url: \(url)")
        print(response.result.error)
        if let failure = failure {
          dispatch_async(dispatch_get_main_queue(), failure)
        }
      }
    }
  }
  
  
  class func getJsonStringFromUrl(url: String, var parameters: [String: String] = Dictionary<String, String>(), appendPass: Bool = true, success: (json: String) -> (), failure: (() -> ())? = nil) {
    print("Fetching URL: \(url)")
    if appendPass {
      parameters["pass"] = "plJR86!!"
    }
    Alamofire.request(.GET, url, parameters: parameters)
      .validate(statusCode: 200..<300).responseString {
        response in
        
        if response.result.isSuccess {
          success(json: response.result.value!)
        }
        else {
          print("Failure: \(response.result.error)")
          if let failure = failure {
            dispatch_async(dispatch_get_main_queue(), failure)
          }
        }
    }
  }
  
  class func parseJSON(data: NSData) -> [String: AnyObject]? {
    do {
      if let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
        return json
      } else {
        print("Unknown JSON error")
        
      }
    }
    catch let error as NSError {
      print("JSON error: \(error)")
    }
    catch {
      print("Undefined error")
    }
    return nil
  }  
}