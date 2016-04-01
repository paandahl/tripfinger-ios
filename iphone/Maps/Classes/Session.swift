import Foundation
import RealmSwift
import BrightFutures

class Session {
  
  var searchService: SearchService
    
  init() {
    
//    let mapsFileUrl = NSBundle.mainBundle().URLForResource("mapsObject", withExtension: "json")!
//    let json = JSON(data: NSData(contentsOfURL: mapsFileUrl)!).rawString()!
    searchService = SearchService()
  }
  
  // guide hierarchy
  var currentItem: GuideItem!
  var currentRegion: Region!
  
  var currentCountry: Region!
  var currentSubRegion: Region!
  var currentCity: Region!
  
  var sectionStack = [GuideText]()
  var currentSection: GuideText!
  
//  func loadCurrentCountry(failure: () -> (), handler: () -> ()) {
//    loadRegionIfNecessary(currentCountry, failure: failure, handler: handler)
//  }
  
  func loadRegionFromId(regionId: String, failure: () -> (), handler: () -> ()) {
//    currentRegion = Region.constructRegion(searchResult.name, fromSearchResult: true)
//    currentItem = currentRegion.item()
    ContentService.getRegionWithId(regionId, failure: failure) {
      region in
      
      self.changeRegion(region, failure: failure) {
        handler()        
      }
    }
  }
  
  func moveBackInHierarchy(failure: () -> (), handler: () -> ()) {
    
    if currentSection != nil && sectionStack.count > 0 {
      currentSection = nil
      changeSection(sectionStack.popLast()!, failure: failure, handler: handler)
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
      changeRegion(newRegion, failure: failure, handler: handler)
    }
  }
  
  func setRegionVars(region: Region!) {
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
  }
  
  /* The handler is only necessary if you pass a region that might need unwrapping.
  */
  func changeRegion(region: Region!, failure: () -> (), handler: (() -> ())! = nil) {
    
    setRegionVars(region)
    sectionStack = [GuideText]()
    currentSection = nil
    currentRegion = region
    currentItem = region != nil ? region.listing.item : nil
    loadRegionIfNecessary(region, failure: failure, handler: handler)
  }
  
  private func loadRegionIfNecessary(region: Region!, failure: () -> (), handler: (() -> ())! = nil) {
    if region != nil && region.listing.item.loadStatus != GuideItem.LoadStatus.FULLY_LOADED {
      ContentService.getRegionFromListing(region.listing, failure: failure) {
        region in
        self.setRegionVars(region)
        self.currentRegion = region
        self.currentItem = region.listing.item
        print("Setting region \(region.getName()) with category: \(region.item().category)")
        handler()
      }
    } else {
      if handler != nil {
        handler()
      }
    }
  }
  
  func changeSection(section: GuideText, failure: () -> (), handler: (() -> ())) {
    if currentSection != nil {
      sectionStack.append(currentSection)
    }
    currentSection = section
    currentItem = section.item
    if section.item.loadStatus != GuideItem.LoadStatus.FULLY_LOADED  {
      ContentService.getGuideTextWithId(currentRegion, guideTextId: section.getId(), failure: failure) {
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
  
  // listings (swipe and list view)
  var listingsFromRegion: String?
  var listingsFromCategory: Listing.Category?
  var currentCategory = Listing.Category.ATTRACTIONS
  var currentSubCategory: Listing.SubCategory?
  var currentListings = List<Listing>()
  
  var listingsFuture: Future<Void, NoError>?
  func loadListings(failure: () -> (), handler: () -> ()) {

    if let attractionsFuture = listingsFuture {
      print("Listings loading already in progress")
      attractionsFuture.onComplete { _ in
        handler()
      }
    } else {
      if listingsFromRegion != currentRegion?.item().name || listingsFromCategory != currentCategory {
        print("Reloading listings")
        let promise = Promise<Void, NoError>()
        listingsFuture = promise.future
        let failureHandler = {
          self.listingsFuture = nil
          failure()
        }
        ContentService.getCascadingListingsForRegion(self.currentRegion, withCategory: currentCategory, failure: failureHandler) {
          listings in
          
          self.listingsFromCategory = self.currentCategory
          self.listingsFromRegion = self.currentRegion?.item().name
          print("Loaded \(listings.count) listings.")
          self.currentListings = listings
          handler()
          promise.success()
          print("Setting listingsFuture to nil")
          self.listingsFuture = nil
        }
      } else {
        print("No need to reload listings")
        handler()
      }
    }
  }
}