import Foundation
import RealmSwift
import SwiftyJSON

class JsonParserService {
  
  class func parseGuideItem(json: JSON) -> GuideItem {
    return parseGuideItem(GuideItem(), withJson: json)
  }
  
  class func parseGuideItem(guideItem: GuideItem, withJson json: JSON) -> GuideItem {
    guideItem.name = json["name"].string
    guideItem.versionId = json["id"].string
    guideItem.uuid = json["uuid"].string!
    guideItem.slug = json["slug"].string
    guideItem.content = json["description"].string
    guideItem.category = json["category"].int!
    guideItem.subCategory = json["subCategory"].int!
    guideItem.status = json["status"].int!
    guideItem.parent = json["parentUuid"].string
    guideItem.textLicense = json["textLicense"].string
    guideItem.offline = false
    guideItem.loadStatus = GuideItem.LoadStatus.FULLY_LOADED
    for imageJson in json["images"].array! {
      let image = GuideItemImage()
      image.url = imageJson["url"].string
      image.license = imageJson["license"].string
      image.artist = imageJson["artist"].string
      image.originalUrl = imageJson["originalUrl"].string
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
    listing.continent = json["continent"].string
    listing.worldArea = json["worldArea"].string
    listing.country = json["country"].string
    listing.subRegion = json["subRegion"].string
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
    
    if fetchChildren { 
      parseChildren(guideText, withJson: json)
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
    region.mwmRegionId = json["mwmRegionId"].string
    region.listing = parseGuideListing(json)
    region.listing.item = parseGuideItem(json)
    
    if (fetchChildren) {
      parseChildren(region, withJson: json)
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
  
  class func parseSimplePoi(json: JSON) -> SimplePOI {
    let simplePoi = SimplePOI()
    simplePoi.name = json["name"].string
    simplePoi.location = json["location"].string!
    simplePoi.category = json["category"].int!
    simplePoi.subCategory = json["subCategory"].int!
    simplePoi.location = json["location"].string
    simplePoi.latitude = json["latitude"].double!
    simplePoi.longitude = json["longitude"].double!
    simplePoi.listingId = json["id"].string!
    return simplePoi
  }
  
  class func parseSimplePois(json: JSON) -> List<SimplePOI> {
    let searchResults = List<SimplePOI>()
    for resultJson in json.array! {
      searchResults.append(parseSimplePoi(resultJson))
    }
    return searchResults
  }


  class func parseRegionTreeFromJson(json: JSON) -> Region {
    let region = Region()
    region.mwmRegionId = json["mwmRegionId"].string
    region.listing = parseGuideListing(json)
    region.listing.item.guideSections = parseSectionTreeFromJson(json["guideSections"])
    region.listing.item.categoryDescriptions = parseSectionTreeFromJson(json["categoryDescriptions"])
    if  json["attractions"].array != nil {
      region.listings.appendContentsOf(parseListings(json["attractions"]))
    }
    if json["subRegions"].array != nil {
      region.listing.item.subRegions.appendContentsOf(parseRegionTreesFromJson(json["subRegions"]))
    }
    return region
  }
  
  class func parseListings(jsonArray: JSON) -> List<Listing> {
    let listings = List<Listing>()
    for json in jsonArray.array! {
      let listing = parseListing(json)
      if listing.listing.latitude != 0.0 && listing.listing.longitude != 0.0 {
        listings.append(listing)
      }
    }
    return listings
  }
  
  class func parseListing(json: JSON) -> Listing {
    let listing = Listing()
    listing.listing = parseGuideListing(json)
    listing.address = json["address"].string
    listing.website = json["url"].string
    listing.phone = json["phone"].string
    listing.email = json["email"].string
    listing.price = json["price"].string
    listing.openingHours = json["openingHours"].string
    listing.directions = json["directions"].string
    return listing
  }
  
  class func parseSectionTreeFromJson(json: JSON) -> List<GuideText> {
    let guideSections = List<GuideText>()
    for guideSectionObj in json.array! {
      let guideSection = parseGuideText(guideSectionObj)      
      guideSection.item.guideSections = parseSectionTreeFromJson(guideSectionObj["guideSections"])
      if guideSectionObj["categoryDescriptions"].array != nil {
        guideSection.item.categoryDescriptions = parseSectionTreeFromJson(guideSectionObj["categoryDescriptions"])
      }
      guideSection.item.loadStatus = GuideItem.LoadStatus.CHILDREN_NOT_LOADED
      guideSections.append(guideSection)
    }
    return guideSections
  }
  
  class func parseChildren(guideText: GuideText, withJson json: JSON) {
    guideText.item.guideSections = parseSectionTreeFromJson(json["guideSections"])
    if json["categoryDescriptions"].array != nil {
      guideText.item.categoryDescriptions = parseSectionTreeFromJson(json["categoryDescriptions"])      
    }
  }
  
  class func parseChildren(region: Region, withJson json: JSON) {
    region.item().guideSections = parseSectionTreeFromJson(json["guideSections"])
    region.item().categoryDescriptions = parseCategoryDescriptions(region, guideItemJson: json)
    let subRegions = List<Region>()
    for subRegion in parseRegions(json["subRegions"]) {
      subRegion.item().loadStatus = GuideItem.LoadStatus.CHILDREN_NOT_LOADED
      subRegions.append(subRegion)
    }
    region.item().subRegions = subRegions
  }
  
  internal class func parseCategoryDescriptions(region: Region, guideItemJson: JSON) -> List<GuideText> {
    let categoryDescriptions = parseSectionTreeFromJson(guideItemJson["categoryDescriptions"])
    
    print("Returning \(categoryDescriptions.count) category descriptions")
    let sorted = categoryDescriptions.sort({ (el1, el2) -> Bool in el1.item.category < el2.item.category })
    let sortedList = List<GuideText>()
    sortedList.appendContentsOf(sorted)
    return sortedList
  }
  
  internal class func parseSubcategoryDescriptions(categoryDescription: GuideText, guideItemJson: JSON) -> List<GuideText> {
    let subcategoryDescriptions = parseSectionTreeFromJson(guideItemJson["guideSections"])
    let sorted = subcategoryDescriptions.sort({ (el1, el2) -> Bool in el1.item.subCategory < el2.item.subCategory })
    let sortedList = List<GuideText>()
    sortedList.appendContentsOf(sorted)
    return sortedList
  }
}