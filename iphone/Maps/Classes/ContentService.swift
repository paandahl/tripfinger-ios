import Foundation
import RealmSwift
import Alamofire
import CoreLocation
import SwiftyJSON

typealias ContentLoaded = (guideItem: GuideItem) -> ()

class ContentService {
  
  init() {}
  
  class func getPois(bottomLeft: CLLocationCoordinate2D, topRight: CLLocationCoordinate2D, zoomLevel: Int, category: Listing.Category, failure: () -> (), handler: [SimplePOI] -> ()) -> Request {
    
    let bounds = "\(bottomLeft.latitude),\(bottomLeft.longitude),\(topRight.latitude),\(topRight.longitude)"
    let parameters = ["categoryId": "\(category.rawValue)"]
    let url = TripfingerAppDelegate.serverUrl + "/search_by_bounds/\(bounds)/\(zoomLevel)"
    return NetworkUtil.getJsonFromUrl(url, parameters: parameters, failure: failure) { json in
      
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
    }
  }
  
  class func getCountries(failure: () -> (), handler: [Region] -> ()) {
    NetworkUtil.getJsonFromUrl(TripfingerAppDelegate.serverUrl + "/countries", failure: failure) { json in
      let regions = JsonParserService.parseRegions(json)
      dispatch_async(dispatch_get_main_queue()) {
        handler(regions)
      }
    }
  }
  
  class func getGuideTextsForGuideItem(guideItem: GuideItem, failure: () -> (), handler: (guideTexts: [GuideText]) -> ()) {
    let url = TripfingerAppDelegate.serverUrl + "/regions/\(guideItem.uuid)/guideTexts"
    NetworkUtil.getJsonFromUrl(url, failure: failure) { json in
      let guideTexts = JsonParserService.parseGuideTexts(json)
      dispatch_async(dispatch_get_main_queue()) {
        handler(guideTexts: guideTexts)
      }
    }
  }
  
  // Can fetch a country by name or mwmRegionId
  class func getCountryWithName(name: String, failure: () -> (), handler: Region -> ()) {
    if let region = DatabaseService.getCountry(name) {
      handler(region)
      return
    }
    NetworkUtil.getJsonFromUrl(TripfingerAppDelegate.serverUrl + "/countries/\(name)", failure: failure) { json in
      let region = JsonParserService.parseRegion(json)
      dispatch_async(dispatch_get_main_queue()) {
        handler(region)
      }
    }
  }
  
  class func getCountryForRegion(region: Region, failure: () -> (), handler: Region -> ()) {
    if region.getCategory() == Region.Category.COUNTRY {
      handler(region)
    } else {
      ContentService.getCountryWithName(region.listing.country!, failure: failure) { country in
        handler(country)
      }
    }
  }
  
  class func getSubRegionWithName(subRegionName: String, countryName: String, failure: () -> (), handler: Region -> ()) {
    if let region = DatabaseService.getSubRegionOrCity(countryName, itemName: subRegionName) {
      handler(region)
      return
    }
    let url = TripfingerAppDelegate.serverUrl + "/subRegions/\(countryName)/\(subRegionName)"
    NetworkUtil.getJsonFromUrl(url, failure: failure) { json in
      let region = JsonParserService.parseRegion(json)
      dispatch_async(dispatch_get_main_queue()) {
        handler(region)
      }
    }
  }

  class func getCityWithName(cityName: String, countryName: String, failure: () -> (), handler: Region -> ()) {
    if let region = DatabaseService.getCity(countryName, cityName: cityName) {
      handler(region)
      return
    }
    let url = TripfingerAppDelegate.serverUrl + "/cities/\(countryName)/\(cityName)"
    NetworkUtil.getJsonFromUrl(url, failure: failure) { json in
      let region = JsonParserService.parseRegion(json)
      dispatch_async(dispatch_get_main_queue()) {
        handler(region)
      }
    }
  }

  class func getRegionWithSlug(slug: String, failure: () -> (), handler: Region -> ()) {
    if let region = DatabaseService.getRegionWithSlug(slug) {
      handler(region)
      return
    }
    let parameters: [String: String] = ["slug": "true"]
    let url = TripfingerAppDelegate.serverUrl + "/regions/\(slug)"
    NetworkUtil.getJsonFromUrl(url, parameters: parameters, failure: failure) { json in
      let region = JsonParserService.parseRegion(json)
      dispatch_async(dispatch_get_main_queue()) {
        handler(region)
      }
    }
  }

  class func getRegionWithId(regionId: String, failure: () -> (), handler: Region -> ()) {
    if let region = DatabaseService.getRegionWithId(regionId) {
      handler(region)
      return
    }
    let url = TripfingerAppDelegate.serverUrl + "/regions/\(regionId)"
    NetworkUtil.getJsonFromUrl(url, failure: failure) { json in
      let region = JsonParserService.parseRegion(json)
      dispatch_async(dispatch_get_main_queue()) {
        handler(region)
      }
    }
  }
  
  class func getGuideTextWithId(guideTextId: String, failure: () -> (), handler: GuideText -> ()) {
    if let guideText = DatabaseService.getGuideTextWithId(guideTextId) {
      handler(guideText)
      return
    }
    let url = TripfingerAppDelegate.serverUrl + "/guideTexts/\(guideTextId)"
    NetworkUtil.getJsonFromUrl(url, failure: failure) { json in
      let guideText = JsonParserService.parseGuideText(json, fetchChildren: true)
      dispatch_async(dispatch_get_main_queue()) {
        handler(guideText)
      }
    }
  }
  
  class func getListingWithId(attractionId: String, failure: () -> (), withNotes: Bool = true, handler: Listing -> ()) {
    if let attraction = DatabaseService.getListingWithId(attractionId) {
      handler(attraction)
      return
    }
    getListingWithIdentifier(attractionId, failure: failure, withNotes: withNotes, handler: handler)
  }
  
  class func getListingWithSlug(slug: String, failure: () -> (), withNotes: Bool = true, handler: Listing -> ()) {
    if let listing = DatabaseService.getListingWithSlug(slug) {
      handler(listing)
      return
    }
    getListingWithIdentifier(slug, failure: failure, withNotes: withNotes, handler: handler)
  }
  
  private class func getListingWithIdentifier(identifier: String, failure: () -> (), withNotes: Bool = true, handler: Listing -> ()) {
    let url = TripfingerAppDelegate.serverUrl + "/attractions/\(identifier)"
    NetworkUtil.getJsonFromUrl(url, failure: failure) { json in
      let attraction = JsonParserService.parseListing(json)
      
      if withNotes {
        dispatch_async(dispatch_get_main_queue()) {
          if let notes = DatabaseService.getListingNotes(attraction.item().uuid) {
            attraction.listing.notes = notes
          }
          handler(attraction)
        }
      } else {
        handler(attraction)
      }
    }
  }
    
  class func getCascadingListingsForRegion(regionId: String, withCategory category: Int? = nil, failure: () -> (), handler: [Listing] -> ()) {
    let offlineRegion = DatabaseService.getRegionWithId(regionId)
    if !NetworkUtil.connectedToNetwork() || offlineRegion != nil {
      let attractions = DatabaseService.getCascadingListingsForRegion(offlineRegion, category: category)
      handler(attractions)
      return
    }
    var url: String
    var parameters: [String: String] = ["cascade": "true"]
    url = TripfingerAppDelegate.serverUrl + "/regions/\(regionId)/attractions"
    
    if let category = category {
      parameters["categoryId"] = String(category)
    }
    
    NetworkUtil.getJsonFromUrl(url, parameters: parameters, failure: failure) { json in
      dispatch_async(dispatch_get_main_queue()) {
        let listings = JsonParserService.parseListings(json)
        for listing in listings {
          if let notes = DatabaseService.getListingNotes(listing.item().uuid) {
            listing.listing.notes = notes
          }
        }
        handler(listings)
      }
    }
  }
}