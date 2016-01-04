import Foundation
import RealmSwift
import BrightFutures

class Session {
  
  init() {}

  var currentItemId: String!
  var currentCountry: Region?

  var currentRegion: Region? {
    didSet {
      if currentRegion?.listing.item.category == Region.Category.COUNTRY.rawValue {
        currentCountry = currentRegion
      }
    }
  }
  var currentSection: GuideText?
  var currentCategory = Attraction.Category.EXPLORE_CITY

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