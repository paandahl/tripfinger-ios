import Foundation
import RealmSwift
import BrightFutures

class Session: NSObject {
  
  // listings (swipe and list view)
  var listingsFromRegion: String?
  var listingsFromCategory: Listing.Category?
  var listingsFromSubCategory: Listing.SubCategory?
  var currentCategory = Listing.Category.ATTRACTIONS
  var currentSubCategory: Listing.SubCategory?
  var currentListings = List<Listing>()
  
  var listingsFuture: Future<Void, NoError>?
  
  func loadListings(failure: () -> (), handler: () -> ()) {

//    if let attractionsFuture = listingsFuture {
//      print("Listings loading already in progress")
//      attractionsFuture.onComplete { _ in
//        handler()
//      }
//    } else {
//      if listingsFromRegion != currentRegion?.item().name || listingsFromCategory != currentCategory || listingsFromSubCategory != currentSubCategory {
//        print("Reloading listings")
//        let promise = Promise<Void, NoError>()
//        listingsFuture = promise.future
//        let failureHandler = {
//          self.listingsFuture = nil
//          failure()
//        }
//        let category = currentSubCategory != nil ? currentSubCategory!.rawValue : currentCategory.rawValue
//        ContentService.getCascadingListingsForRegion(self.currentRegion, withCategory: category, failure: failureHandler) {
//          listings in
//          
//          self.listingsFromCategory = self.currentCategory
//          self.listingsFromRegion = self.currentRegion?.item().name
//          print("Loaded \(listings.count) listings.")
//          self.currentListings = listings
//          handler()
//          promise.success()
//          print("Setting listingsFuture to nil")
//          self.listingsFuture = nil
//        }
//      } else {
//        print("No need to reload listings")
//        handler()
//      }
//    }
  }
}