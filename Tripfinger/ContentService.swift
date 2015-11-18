import Foundation
import RealmSwift

typealias ContentLoaded = (guideItem: GuideItem) -> ()

class ContentService {
  
  static let baseUrl = "http://tripfinger-server.appspot.com"
  
  init() {}
  
  class func getGuideTextsForGuideItem(guideItem: GuideItem, handler: (guideTexts: [GuideText]) -> ()) {
    let id = String(guideItem.id!)
    getJsonFromUrl(baseUrl + "/regions/\(id)/guideTexts", success: {
      json in
      
      let guideTexts = self.parseGuideTexts(json!)
      
      dispatch_async(dispatch_get_main_queue()) {
        handler(guideTexts: guideTexts)
      }
      }, failure: nil)
  }
  
  class func getFullRegionTree(regionId: String, handler: (region: Region) -> ()) {
    getJsonFromUrl(baseUrl + "/regions/\(regionId)/full", success: {
      json in
      
      let region = self.parseRegionTreeFromJson(json!)
      
      dispatch_async(dispatch_get_main_queue()) {
        handler(region: region)
      }
      }, failure: nil)
  }
  
  
  class func getDescriptionForCategory(categoryId: Int, forRegion region: Region, handler: (categoryDescription: GuideText) -> ()) {
    
    let regionId = String(region.listing.item.id!)
    getJsonFromUrl(baseUrl + "/regions/\(regionId)/guideTextForCategory/\(categoryId)", success: {
      json in
      
      var guideText: GuideText
      if let json = json {
        guideText = self.parseGuideText(json)
      }
      else {
        guideText = GuideText()
        guideText.item = GuideItem()
      }
      
      dispatch_async(dispatch_get_main_queue()) {
        handler(categoryDescription: guideText)
      }
      }, failure: nil)
  }
  
  class func getRegions(handler: [Region] -> ()) {
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
  
  class func getRegionWithId(regionId: String, handler: Region -> ()) {
    getJsonFromUrl(baseUrl + "/regions/\(regionId)", success: {
      json in
      
      let region = self.parseRegion(json!)
      
      dispatch_async(dispatch_get_main_queue()) {
        handler(region)
        
      }}, failure: nil)
  }
  
  class func getGuideTextWithId(guideTextId: String, handler: GuideText -> ()) {
    getJsonFromUrl(baseUrl + "/guideTexts/\(guideTextId)", success: {
      json in
      
      let guideText = self.parseGuideText(json!, fetchChildren: true)
      
      dispatch_async(dispatch_get_main_queue()) {
        handler(guideText)
        
      }}, failure: nil)
  }
  
  class func getAttractionsForRegion(region: Region, handler: [Attraction] -> ()) {
    getJsonFromUrl(baseUrl + "/regions/\(region.listing.item.id)/attractions", success: {
      json in
      
      let attractions = self.parseAttractions(json!)
      
      dispatch_async(dispatch_get_main_queue()) {
        handler(attractions)
        
      }}, failure: nil)
    
  }
  
  class func getAttractionsForRegion(region: Region, withCategory category: Attraction.Category, handler: [Attraction] -> ()) {
    getJsonFromUrl(baseUrl + "/regions/\(region.listing.item.id)/attractions/\(category.rawValue)", success: {
      json in
      
      let attractions = self.parseAttractions(json!)
      
      dispatch_async(dispatch_get_main_queue()) {
        handler(attractions)
        
      }}, failure: nil)
    
  }
  
  class func getJsonFromUrl(url: String, success: (json: JSON?) -> (), failure: (() -> ())?) {
    print("Fetching URL: \(url)")
    let nsUrl = NSURL(string: url)
    let session = NSURLSession.sharedSession()
    let dataTask = session.dataTaskWithURL(nsUrl!) {
      data, response, error in
      
      if let error = error {
        print("Failure! \(error)")
        if error.code == -999 { return }
      }
      else if let httpResponse = response as? NSHTTPURLResponse {
        if httpResponse.statusCode == 200 {
          
          let json = JSON(data: data!)
          success(json: json)
          return
        }
        else if httpResponse.statusCode == 404 {
          print("Got 404 from url: \(url)")
          success(json: nil)
        }
        else {
          print("Faulire! \(response)")
        }
      }
      
      if let failure = failure {
        dispatch_async(dispatch_get_main_queue(), failure)
      }
    }
    
    dataTask.resume()
    
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
    return nil
  }
  
  class func parseGuideItem(json: JSON) -> GuideItem {
    return parseGuideItem(GuideItem(), withJson: json)
  }
  
  class func parseGuideItem(guideItem: GuideItem, withJson json: JSON) -> GuideItem {
    guideItem.name = json["name"].string
    guideItem.id = json["id"].string
    guideItem.content = json["description"].string
    guideItem.category = json["category"].int
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
    listing.latitude = json["latitude"].double
    listing.longitude = json["longitude"].double
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
  
  class func parseRegion(json: JSON, fetchChildren: Bool = true) -> Region {
    let region = Region()
    region.listing = GuideListing()
    region.listing.item = parseGuideItem(json)
    
    if (fetchChildren) {
      parseChildren(region.listing.item, withJson: json)
    }
    return region
  }
  
  class func parseRegionTreeFromJson(json: JSON) -> Region {
    let region = Region()
    region.listing = GuideListing()
    region.listing.item = parseGuideItem(json)
    region.listing.item.guideSections = parseSectionTreeFromJson(json["sectionTree"])
    return region
  }
  
  class func parseAttractions(jsonArray: JSON) -> [Attraction] {
    var attractions = [Attraction]()
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
      for categoryDescription in json["categoryDescriptions"].array! {
        categoryDescriptionsDict[categoryDescription[0].int!] = categoryDescription[1].string!
      }
      for category in Attraction.Category.allValues {
        let categoryDescription = GuideText()
        categoryDescription.item = GuideItem()
        let categoryDescriptionId = categoryDescriptionsDict[category.rawValue]
        if (categoryDescriptionId != nil) {
          categoryDescription.item.id = categoryDescriptionId!
        }
        else {
          categoryDescription.item.id = "null"
        }
      }
      guideItem.categoryDescriptions = categoryDescriptions
      
    }
    guideItem.guideSections = guideSections
  }
}