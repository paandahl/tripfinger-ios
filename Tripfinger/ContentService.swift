import Foundation
import RealmSwift
import Alamofire

typealias ContentLoaded = (guideItem: GuideItem) -> ()

class ContentService {
  
  static let baseUrl = "https://server.tripfinger.com"
  
  init() {}
  
  class func getPois(bottomLeft: CLLocationCoordinate2D, topRight: CLLocationCoordinate2D, handler: List<SearchResult> -> ()) {
    
    let bounds = "\(bottomLeft.latitude),\(bottomLeft.longitude),\(topRight.latitude),\(topRight.longitude)"
    getJsonFromUrl(ContentService.baseUrl + "/search_by_bounds/\(bounds)", success: {
      json in
      
      let searchResults = SearchService().parseSearchResults(json)
      
      dispatch_async(dispatch_get_main_queue()) {
        handler(searchResults)
      }
      }, failure: nil)
  }

  
  class func getCountries(handler: [Region] -> ()) {
    getJsonFromUrl(baseUrl + "/countries", success: {
      json in
      
      let regions = parseRegions(json)
      
      dispatch_async(dispatch_get_main_queue()) {
        handler(regions)
      }
      
      }, failure: nil)
  }
  
  class func getGuideTextsForGuideItem(guideItem: GuideItem, handler: (guideTexts: [GuideText]) -> ()) {
    let id = String(guideItem.id!)
    getJsonFromUrl(baseUrl + "/regions/\(id)/guideTexts", success: {
      json in
      
      let guideTexts = self.parseGuideTexts(json)
      
      dispatch_async(dispatch_get_main_queue()) {
        handler(guideTexts: guideTexts)
      }
      }, failure: nil)
  }
  
  class func getFullRegionTree(regionId: String, handler: (region: Region) -> ()) {
    getJsonFromUrl(baseUrl + "/regions/\(regionId)/full", success: {
      json in
      
      let region = self.parseRegionTreeFromJson(json)
      
      dispatch_async(dispatch_get_main_queue()) {
        handler(region: region)
      }
      }, failure: nil)
  }
    
  class func getRegions(handler: [Region] -> ()) {
    getJsonFromUrl(baseUrl + "/regions", success: {
      json in
      
      var regions = [Region]()
      for regionJson in json.array! {
        regions.append(self.parseRegion(regionJson, fetchChildren: false))
      }
      
      dispatch_async(dispatch_get_main_queue()) {
        handler(regions)
        
      }
      
      }, failure: nil)
  }
  
  class func getRegionWithId(regionId: String, failure: (() -> ())? = nil, handler: Region -> ()) {
    if let region = OfflineService.getRegionWithId(regionId) {
      handler(region)
      return
    }
    getJsonFromUrl(baseUrl + "/regions/\(regionId)", success: {
      json in
      
      let region = self.parseRegion(json)
      
      dispatch_async(dispatch_get_main_queue()) {
        handler(region)
        
      }}, failure: {
        if let failure = failure {
          failure()
        }
    })
  }
  
  class func getGuideTextWithId(region: Region, guideTextId: String, handler: GuideText -> ()) {
    if region.offline {
      handler(OfflineService.getGuideTextWithId(region, guideTextId: guideTextId))
      return
    }
    getJsonFromUrl(baseUrl + "/guideTexts/\(guideTextId)", success: {
      json in
      
      let guideText = self.parseGuideText(json, fetchChildren: true)
      
      dispatch_async(dispatch_get_main_queue()) {
        handler(guideText)
        
      }})
  }
  
  class func getAttractionWithId(attractionId: String, handler: Attraction -> ()) {
    if let attraction = OfflineService.getAttractionWithId(attractionId) {
      handler(attraction)
      return
    }
    getJsonFromUrl(baseUrl + "/attractions/\(attractionId)", success: {
      json in
      
      let attraction = self.parseAttraction(json)
      
      dispatch_async(dispatch_get_main_queue()) {
        handler(attraction)
      }
    })

  }
  
  class func getAttractionsForRegion(region: Region?, handler: List<Attraction> -> ()) {
    getAttractionsForRegion(region, withCategory: nil, handler: handler)
  }
  
  class func getAttractionsForRegion(region: Region?, withCategory category: Attraction.Category?, handler: List<Attraction> -> ()) {
    var regionId = "world"
    var parameters = ["cascade": "world"]
    var categoryPart = ""
    
    if let region = region {
      if region.offline {
        handler(region.attractions)
        return
      }
      if region.listing.item.category == Region.Category.CONTINENT.rawValue {
        parameters["cascade"] = "continent"
      }
      else if region.listing.item.category == Region.Category.COUNTRY.rawValue {
        parameters["cascade"] = "country"
      }
      else if region.listing.item.category == Region.Category.CITY.rawValue {
        parameters["cascade"] = "city"
      }
      regionId = region.listing.item.id
    }
    
    if let category = category {
      categoryPart = "/\(category.rawValue)"
    }
    
    getJsonFromUrl(baseUrl + "/regions/\(regionId)/attractions\(categoryPart)", parameters: parameters, success: {
      json in
      
      let attractions = self.parseAttractions(json)
      
      dispatch_async(dispatch_get_main_queue()) {
        handler(attractions)
        
      }}, failure: nil)
    
  }
  
  class func getJsonFromUrl(url: String, var parameters: [String: String] = Dictionary<String, String>(), method: Alamofire.Method = .GET, appendPass: Bool = true, success: (json: JSON) -> (), failure: (() -> ())? = nil) {
    if appendPass {
      parameters["pass"] = "plJR86!!"
    }
    print("Fetching URL: \(url)")
    
    let request = Alamofire.request(method, url, parameters: parameters).validate(statusCode: 200..<300)
    let backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

    request.response(
      queue: backgroundQueue,
      responseSerializer: Request.JSONResponseSerializer(options: .AllowFragments),
      completionHandler: {
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
    })
  }

  class func getJsonFromPost(var url: String, body: String, appendPass: Bool = true, success: (json: JSON) -> (), failure: (() -> ())? = nil) {
    
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
  
  class func parseGuideItem(json: JSON) -> GuideItem {
    return parseGuideItem(GuideItem(), withJson: json)
  }
  
  class func parseGuideItem(guideItem: GuideItem, withJson json: JSON) -> GuideItem {
    guideItem.name = json["name"].string
    guideItem.id = json["id"].string
    guideItem.content = json["description"].string
    guideItem.category = json["category"].int!
    guideItem.parent = json["parent"].string
    for imageJson in json["images"].array! {
      let image = GuideItemImage()
      image.url = imageJson["url"].string
      image.imageDescription = imageJson["description"].string
      guideItem.images.append(image)
    }
    return guideItem
  }
  
  
  class func parseGuideListing(json: JSON) -> GuideListing {
    return parseGuideListing(GuideListing(), withJson: json)
  }
  
  class func parseGuideListing(listing: GuideListing, withJson json: JSON) -> GuideListing {
    listing.item = parseGuideItem(json)
    listing.latitude = json["latitude"].double!
    listing.longitude = json["longitude"].double!
    listing.country = json["country"].string
    listing.city = json["city"].string
    return listing
  }
  
  class func parseGuideTexts(jsonArray: JSON) -> [GuideText] {
    var guideTexts = [GuideText]()
    for json in jsonArray.array! {
      guideTexts.append(parseGuideText(json))
    }
    return guideTexts
  }
  
  class func parseGuideText(json: JSON, fetchChildren: Bool = false) -> GuideText {
    let guideText = GuideText()
    guideText.item = parseGuideItem(json)
    
    if guideText.item.category == 0 && fetchChildren { // GuideSection
      parseChildren(guideText.item, withJson: json, forRegion: false)
    }
    
    return guideText
  }
  
  class func parseRegions(jsonArray: JSON) -> [Region] {
    var regions = [Region]()
    for json in jsonArray.array! {
      regions.append(parseRegion(json, fetchChildren: false))
    }
    return regions
  }
  
  class func parseRegion(json: JSON, fetchChildren: Bool = true) -> Region {
    let region = Region()
    region.listing = parseGuideListing(json)
    region.listing.item = parseGuideItem(json)
    
    if (fetchChildren) {
      parseChildren(region.listing.item, withJson: json)
    }
    return region
  }

  class func parseRegionTreesFromJson(jsonArray: JSON) -> [Region] {
    var regions = [Region]()
    for json in jsonArray.array! {
      regions.append(parseRegionTreeFromJson(json))
    }
    return regions
  }

  class func parseRegionTreeFromJson(json: JSON) -> Region {
    let region = Region()
    region.listing = GuideListing()
    region.listing.item = parseGuideItem(json)
    region.listing.item.guideSections = parseSectionTreeFromJson(json["sectionTree"])
    if  json["attractions"].array != nil {
      region.attractions.appendContentsOf(parseAttractions(json["attractions"]))
    }
    if json["subRegionTree"].array != nil {
      region.listing.item.subRegions.appendContentsOf(parseRegionTreesFromJson(json["subRegionTree"]))      
    }
    return region
  }
  
  class func parseAttractions(jsonArray: JSON) -> List<Attraction> {
    let attractions = List<Attraction>()
    for json in jsonArray.array! {
      attractions.append(parseAttraction(json))
    }
    return attractions
  }
  
  class func parseAttraction(json: JSON) -> Attraction {
    let attraction = Attraction()
    attraction.listing = parseGuideListing(json)
    return attraction
  }
  
  class func parseSectionTreeFromJson(json: JSON) -> List<GuideText> {
    let guideSections = List<GuideText>()
    for guideSectionObj in json.array! {
      let guideSection = parseGuideText(guideSectionObj)
      guideSection.item.guideSections = parseSectionTreeFromJson(guideSectionObj["sectionTree"])
      guideSections.append(guideSection)
    }
    return guideSections
  }
  
  class func parseChildren(guideItem: GuideItem, withJson json: JSON, forRegion: Bool = true) {
    
    let guideSections = List<GuideText>()
    let subRegions = List<Region>()
    let categoryDescriptions = List<GuideText>()
    
    for guideSectionArr in json["guideSections"].array! {
      let guideSection = GuideText()
      guideSection.item = GuideItem()
      guideSection.item.id = guideSectionArr[0].string
      guideSection.item.name = guideSectionArr[1].string
      guideSections.append(guideSection)
    }
    
    if forRegion {
      var categoryDescriptionsDict = Dictionary<Int, String>()
      for categoryDescriptionJson in json["categoryDescriptions"].array! {
        categoryDescriptionsDict[categoryDescriptionJson[0].int!] = categoryDescriptionJson[1].string!
      }
      for category in Attraction.Category.allValues {
        if category == Attraction.Category.ALL {
          continue;
        }
        let categoryDescription = GuideText()
        categoryDescription.item = GuideItem()
        let categoryDescriptionId = categoryDescriptionsDict[category.rawValue]
        categoryDescription.item.category = category.rawValue
        if (categoryDescriptionId != nil) {
          categoryDescription.item.id = categoryDescriptionId!
        }
        else {
          categoryDescription.item.id = "null"
        }
        categoryDescriptions.append(categoryDescription)
      }
      guideItem.categoryDescriptions = categoryDescriptions
      
      for subRegionArr in json["subRegions"].array! {
        let subRegion = Region.constructRegion()
        subRegion.listing.item.id = subRegionArr[0].string
        subRegion.listing.item.name = subRegionArr[1].string
        subRegions.append(subRegion)
      }
      guideItem.subRegions = subRegions;
    }
    guideItem.guideSections = guideSections
    
  }
}