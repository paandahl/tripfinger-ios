import Foundation
import RealmSwift
import BrightFutures

class Session {
  
  var searchService: SearchService
    
  init() {
    
    let mapsFileUrl = NSBundle.mainBundle().URLForResource("mapsObject", withExtension: "json")!
    let json = JSON(data: NSData(contentsOfURL: mapsFileUrl)!).rawString()!
    searchService = SearchService()
  }
  
  // guide hierarchy
  var currentItem: GuideItem!
  var currentRegion: Region!
  
  var currentCountry: Region!
  var currentSubRegion: Region!
  var currentCity: Region!
  
  var previousSection: GuideText!
  var currentSection: GuideText!
  
  func loadRegionFromSearchResult(searchResult: SimplePOI, handler: () -> ()) {
    currentRegion = Region.constructRegion(searchResult.name, fromSearchResult: true)
    currentItem = currentRegion.item()
    ContentService.getRegionWithId(searchResult.listingId) {
      region in
      
      self.changeRegion(region) {
        handler()        
      }
    }
  }
  
  func moveBackInHierarchy(handler: () -> ()) {
    
    if currentSection != nil && previousSection != nil {
      let prev = previousSection
      previousSection = nil
      currentSection = nil
      changeSection(prev, handler: handler)
    }
    else {
      var newRegion: Region!
      if currentSection != nil {
        newRegion = currentRegion
        
      } else {
        switch currentItem.category {
        case Region.Category.NEIGHBOURHOOD.rawValue:
          newRegion = currentCity
        case Region.Category.CITY.rawValue:
          if currentSubRegion != nil {
            newRegion = currentSubRegion
          }
          else {
            newRegion = currentCountry
          }
        case Region.Category.SUB_REGION.rawValue:
          newRegion = currentCountry
        default:
          newRegion = nil
        }
      }
      changeRegion(newRegion, handler: handler)
    }
  }
  
  /* The handler is only necessary if you pass a region that might need unwrapping.
  */
  func changeRegion(region: Region!, handler: (() -> ())! = nil) {
    
    let category = region != nil ? region.listing.item.category : 0
    switch category {
    case Region.Category.COUNTRY.rawValue:
      currentCountry = region
    case Region.Category.SUB_REGION.rawValue:
      currentSubRegion = region
    case Region.Category.CITY.rawValue:
      currentCity = region
    default:
      break
    }
    
    if category < Region.Category.CITY.rawValue {
      currentCity = nil
    }
    if category < Region.Category.SUB_REGION.rawValue {
      currentRegion = nil
    }
    if category < Region.Category.COUNTRY.rawValue {
      currentCountry = nil
    }
    
    let currentCountryName = currentCountry != nil ? currentCountry.getName() : ""
    if category > Region.Category.COUNTRY.rawValue && currentCountryName != region.listing.country {
      currentCountry = Region.constructRegion(region.listing.country)
    }
    let currentSubRegionName = currentSubRegion != nil ? currentSubRegion.getName() : ""
    if category > Region.Category.SUB_REGION.rawValue && currentSubRegionName != region.listing.subRegion {
      if region.listing.subRegion == nil {
        currentSubRegion = nil
      }
      else {
        currentSubRegion = Region.constructRegion(region.listing.subRegion, country: currentCountry.getName())
      }
    }
    let currentCityName = currentCity != nil ? currentCity.getName() : ""
    if category > Region.Category.CITY.rawValue && currentCityName != region.listing.city {
      let subRegion = currentSubRegion == nil ? "city" : currentSubRegion.getName()
      currentCity = Region.constructRegion(region.listing.city, subRegion: subRegion, country: currentCountry.getName())
    }
    
    previousSection = nil
    currentSection = nil
    currentRegion = region
    currentItem = region != nil ? region.listing.item : nil
    
    if region != nil && region.listing.item.loadStatus != GuideItem.LoadStatus.FULLY_LOADED {
      ContentService.getRegionFromListing(region.listing) {
        region in
        
        self.currentRegion = region
        self.currentItem = region.listing.item
        print("Setting region \(region.getName()) with category: \(region.item().category)")
        handler()
      }
    }
    else {
      if handler != nil {
        handler()
      }
    }
  }
  
  func changeSection(section: GuideText, handler: (() -> ())) {
    if currentSection != nil {
      previousSection = currentSection
    }
    currentSection = section
    currentItem = section.item
    if section.item.loadStatus != GuideItem.LoadStatus.FULLY_LOADED  {
      ContentService.getGuideTextWithId(currentRegion, guideTextId: section.getId()) {
        section in
        
        self.currentSection = section
        self.currentItem = section.item
        handler()
      }
    }
    else {
      handler()
    }
  }
  
  // attractions (swipe and list view)
  var attractionsFromRegion: String?
  var attractionsFromCategory: Attraction.Category?
  var currentCategory = Attraction.Category.ATTRACTIONS
  var currentSubCategory: Attraction.SubCategory?
  var currentAttractions = List<Attraction>()
  
  var attractionsFuture: Future<Void, NoError>?
  func loadAttractions(handler: () -> ()) {

    if let attractionsFuture = attractionsFuture {
      attractionsFuture.onComplete { _ in
        handler()
      }
    } else {
      if attractionsFromRegion != currentRegion?.item().name || attractionsFromCategory != currentCategory {
        print("Reloading attractions")
        let promise = Promise<Void, NoError>()
        ContentService.getCascadingAttractionsForRegion(self.currentRegion, withCategory: currentCategory) {
          attractions in
          
          print("Loaded \(attractions.count) attractions.")
          self.currentAttractions = attractions
          handler()
          promise.success()
          self.attractionsFuture = nil
        }
        attractionsFromCategory = currentCategory
        attractionsFromRegion = currentRegion?.item().name
        attractionsFuture = promise.future
      } else {
        print("No need to reload attractions")
        handler()
      }
    }
  }
}