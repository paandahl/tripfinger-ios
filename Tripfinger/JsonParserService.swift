import Foundation
import RealmSwift

class JsonParserService {
  
  class func parseGuideItem(json: JSON) -> GuideItem {
    return parseGuideItem(GuideItem(), withJson: json)
  }
  
  class func parseGuideItem(guideItem: GuideItem, withJson json: JSON) -> GuideItem {
    guideItem.name = json["name"].string
    guideItem.id = json["id"].string
    guideItem.content = json["description"].string
    guideItem.category = json["category"].int!
    guideItem.status = json["status"].int!
    guideItem.parent = json["parent"].string
    guideItem.offline = false
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
    
    if guideText.item.category == 0 && fetchChildren { // GuideSection
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

  class func parseSimplePois(jsonArray: JSON) -> [SimplePOI] {
    var simplePois = [SimplePOI]()
    for json in jsonArray.array! {
      simplePois.append(parseSimplePoi(json))
    }
    return simplePois
  }
  
  class func parseSimplePoi(json: JSON) -> SimplePOI { // TODO: Merge these two functions
    let simplePoi = SimplePOI()
    simplePoi.name = json["name"].string
    simplePoi.category = json["category"].int!
    simplePoi.location = json["location"].string
    let latitude = json["latitude"].double!
    let longitude = json["longitude"].double!
    simplePoi.latitude = latitude
    simplePoi.longitude = longitude
    return simplePoi
  }
  
  class func parseSearchResults(json: JSON) -> List<SimplePOI> {
    let searchResults = List<SimplePOI>()
    for resultJson in json.array! {
      let searchResult = SimplePOI()
      searchResult.name = resultJson["name"].string!
      searchResult.location = resultJson["location"].string!
      searchResult.latitude = resultJson["latitude"].double!
      searchResult.longitude = resultJson["longitude"].double!
      searchResult.category = resultJson["category"].int!
      searchResult.listingId = resultJson["listingId"].string!
      searchResults.append(searchResult)
    }
    return searchResults
  }


  class func parseRegionTreeFromJson(json: JSON) -> Region {
    let region = Region()
    region.listing = parseGuideListing(json)
    region.listing.item.guideSections = parseSectionTreeFromJson(json["sectionTree"])
    if  json["attractions"].array != nil {
      region.attractions.appendContentsOf(parseAttractions(json["attractions"]))
    }
    if json["subRegionTree"].array != nil {
      region.listing.item.subRegions.appendContentsOf(parseRegionTreesFromJson(json["subRegionTree"]))
    }
    if json["simplePOIs"].array != nil {
      region.listing.item.simplePois.appendContentsOf(parseSimplePois(json["simplePOIs"]))
    }
    return region
  }
  
  class func parseAttractions(jsonArray: JSON) -> List<Attraction> {
    let attractions = List<Attraction>()
    for json in jsonArray.array! {
      let attraction = parseAttraction(json)
      if attraction.listing.latitude != 0.0 && attraction.listing.longitude != 0.0 && attraction.item().images.count > 0 {
        attractions.append(attraction)
      }
    }
    return attractions
  }
  
  class func parseAttraction(json: JSON) -> Attraction {
    let attraction = Attraction()
    attraction.listing = parseGuideListing(json)
    attraction.price = json["price"].string
    attraction.openingHours = json["openingHours"].string
    attraction.directions = json["directions"].string
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
  
  class func parseChildren(guideText: GuideText, withJson json: JSON) {
    guideText.item.guideSections = parseGuideSections(json)
  }
  
  class func parseChildren(region: Region, withJson json: JSON) {
    region.item().guideSections = parseGuideSections(json)
    region.item().categoryDescriptions = parseCategoryDescriptions(region, guideItemJson: json)
    let subRegions = List<Region>()
    for subRegion in parseRegions(json["subRegions"]) {
      subRegion.item().childrenLoaded = false
      subRegions.append(subRegion)
    }
    region.item().subRegions = subRegions
  }
  
  internal class func parseCategoryDescriptions(region: Region, guideItemJson: JSON) -> List<GuideText> {
    let categoryDescriptions = List<GuideText>()
    var categoryDescriptionsDict = Dictionary<Int, String>()
    for categoryDescriptionJson in guideItemJson["categoryDescriptions"].array! {
      categoryDescriptionsDict[categoryDescriptionJson[0].int!] = categoryDescriptionJson[1].string!
    }
    for category in Attraction.Category.allValues {
      if category == Attraction.Category.ALL {
        continue;
      }
      let categoryDescription = GuideText()
      categoryDescription.item = GuideItem()
      categoryDescription.item.category = category.rawValue
      categoryDescription.item.name = category.entityName(region)
      let categoryDescriptionId = categoryDescriptionsDict[category.rawValue]
      if (categoryDescriptionId != nil) {
        categoryDescription.item.childrenLoaded = false
        categoryDescription.item.id = categoryDescriptionId
      }
      else {
        categoryDescription.item.content = nil
        categoryDescription.item.childrenLoaded = true
      }
      categoryDescriptions.append(categoryDescription)
    }
    
    return categoryDescriptions
  }
  
  internal class func parseGuideSections(guideItemJson: JSON) -> List<GuideText> {
    let guideSections = List<GuideText>()
    if let guideSectionsJson = guideItemJson["guideSections"].array {
      for guideSectionArr in guideSectionsJson {
        let guideSection = GuideText()
        guideSection.item = GuideItem()
        guideSection.item.childrenLoaded = false
        guideSection.item.id = guideSectionArr[0].string
        guideSection.item.name = guideSectionArr[1].string
        guideSections.append(guideSection)
      }
    }
    return guideSections
  }
}