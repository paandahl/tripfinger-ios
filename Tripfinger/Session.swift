import Foundation
import RealmSwift
import BrightFutures

class Session {
  
  init() {}
  
  // guide hierarchy
  var currentItem: GuideItem!
  var currentRegion: Region!
  
  var currentContinent: Region!
  var currentCountry: Region!
  var currentCity: Region!

  var previousSection: GuideText!
  var currentSection: GuideText!

  func loadRegionFromSearchResult(searchResult: SearchResult, handler: () -> ()) {
    currentRegion = Region.constructRegion(searchResult.name, fromSearchResult: true)
    currentItem = currentRegion.item()
    ContentService.getRegionWithId(searchResult.listingId) {
      region in
      
      self.changeRegion(region)
      handler()
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
        changeRegion(currentRegion, handler: handler)
      }
      else {
        switch currentItem.category {
        case Region.Category.NEIGHBOURHOOD.rawValue:
          newRegion = currentCity
        case Region.Category.CITY.rawValue:
          newRegion = currentCountry
        case Region.Category.COUNTRY.rawValue:
          newRegion = currentContinent
        default:
          newRegion = nil
        }
        changeRegion(newRegion, handler: handler)
      }
    }
  }
  
  /* The handler is only necessary if you pass a region that might need unwrapping.
   */
  func changeRegion(region: Region!, handler: (() -> ())! = nil) {

    let category = region != nil ? region.listing.item.category : 0
    switch category {
    case Region.Category.CONTINENT.rawValue:
      currentContinent = region
    case Region.Category.COUNTRY.rawValue:
      currentCountry = region
    case Region.Category.CITY.rawValue:
      currentCity = region
    default:
      break
    }
    
    if category < Region.Category.CITY.rawValue {
      currentCity = nil
    }
    if category < Region.Category.COUNTRY.rawValue {
      currentCountry = nil
    }
    if category < Region.Category.CONTINENT.rawValue {
      currentContinent = nil
    }
    
    let currentContinentName = currentContinent != nil ? currentContinent.getName() : ""
    if category > Region.Category.CONTINENT.rawValue && currentContinentName != region.listing.continent {
      currentContinent = Region.constructRegion(region.listing.continent)
    }
    let currentCountryName = currentCountry != nil ? currentCountry.getName() : ""
    if category > Region.Category.COUNTRY.rawValue && currentCountryName != region.listing.country {
      currentCountry = Region.constructRegion(region.listing.country, continent: currentContinent.getName())
    }
    let currentCityName = currentCity != nil ? currentCity.getName() : ""
    if category > Region.Category.CITY.rawValue && currentCityName != region.listing.city {
      currentCity = Region.constructRegion(region.listing.city, country: currentCountry.getName(),
        continent: currentContinent.getName())
    }
    
    previousSection = nil
    currentSection = nil
    currentRegion = region
    currentItem = region != nil ? region.listing.item : nil

    if region != nil && !region.listing.item.contentLoaded {
      ContentService.getRegionFromListing(region.listing) {
        region in
        
        self.currentRegion = region
        self.currentItem = region.listing.item
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
    if !section.item.contentLoaded {
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
  
  // filters
  var currentCategory = Attraction.Category.EXPLORE_CITY
  
  
  var currentGuideSections = List<GuideText>()
  var currentCategoryDescriptions = List<GuideText>()
  
  var currentAttractions = List<Attraction>()
  var attractionsFromCategory: Attraction.Category!
  var attractionsFromRegion: Region!
  var searchService = SearchService()
  
  var mapVersionFileDownloaded: Future<String, NoError>!
  
  
  func loadAttractions(handler: (loaded: Bool) -> ()) {
    
    if (attractionsFromCategory == nil || attractionsFromCategory != currentCategory || attractionsFromRegion != currentRegion) {
      if currentCategory != Attraction.Category.ALL {
        ContentService.getAttractionsForRegion(self.currentRegion, withCategory: currentCategory) {
          attractions in
          
          self.currentAttractions = attractions
          handler(loaded: true)
        }
      }
      else {
        ContentService.getAttractionsForRegion(self.currentRegion) {
          attractions in
          
          self.currentAttractions = attractions
          handler(loaded: true)
        }
      }
      attractionsFromCategory = currentCategory
      attractionsFromRegion = currentRegion
    }
    else {
      handler(loaded: false)
    }
  }
}