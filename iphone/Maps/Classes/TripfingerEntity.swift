import Foundation

//
// Data holder for tripfinger GuideItems, without Realm-dependencies, so that the objects
// can be passed down to the Obj C++-layer
//
@objc public class TripfingerEntity: NSObject {
  
  var lat: Double = 0
  var lon: Double = 0
  var name: String!
  
  var type: Int32 = 0
  var category: Int = 0
  var tripfingerId = ""
  
  var phone = ""
  var address = ""
  var website = ""
  var email = ""
  
  var content = ""
  var price = ""
  var openingHours = ""
  var directions = ""

  var url = ""
  var imageDescription = ""
  var license = ""
  var artist = ""
  var originalUrl = ""
  
  var offline = false
  var liked = false
    
  init(poi: SimplePOI) {
    super.init()
    self.offline = false
    self.name = poi.name
    self.tripfingerId = poi.listingId
    self.lat = poi.latitude
    self.lon = poi.longitude
    self.category = poi.category
    if poi.isListing() {
      self.type = Int32(Listing.SubCategory(rawValue: poi.subCategory)!.osmType)
    } else {
      self.type = Int32(Region.Category(rawValue: poi.category)!.osmType)
    }
  }
  
  init(listing: Listing) {
    self.category = listing.item().category
    self.offline = listing.item().offline
    self.name = listing.item().name
    self.tripfingerId = listing.item().uuid
    self.lat = listing.listing.latitude
    self.lon = listing.listing.longitude
    self.type = Int32(Listing.SubCategory(rawValue: listing.item().subCategory)!.osmType)
    self.address = listing.address ?? ""
    self.website = listing.website ?? ""
    self.phone = listing.phone ?? ""
    self.email = listing.email ?? ""
    
    self.content = listing.item().content ?? ""
    self.openingHours = listing.openingHours ?? ""
    self.directions = listing.directions ?? ""
    self.price = listing.price ?? ""
    
    if listing.item().images.count > 0 {
      let image = listing.item().images[0]
      self.url = image.url ?? ""
      self.imageDescription = image.imageDescription ?? ""
      self.license = image.license ?? ""
      self.artist = image.artist ?? ""
      self.originalUrl = image.originalUrl ?? ""
    }
    if let notes = listing.listing.notes where notes.likedState == GuideListingNotes.LikedState.LIKED  {
      self.liked = true
    }
  }
  
  init(region: Region) {
    self.category = region.item().category
    self.offline = region.item().offline
    self.name = region.item().name
    self.tripfingerId = region.item().uuid
    self.lat = region.listing.latitude
    self.lon = region.listing.longitude
    self.type = Int32(Region.Category(rawValue: region.item().category)!.osmType)
  }
  
  func isListing() -> Bool {
    return String(self.category).hasPrefix("2")
  }

  func getFileUrl() -> NSURL {
    return NSURL(string: url, relativeToURL: NSURL.getDirectory(.LibraryDirectory, withPath: "/"))!
  }
}