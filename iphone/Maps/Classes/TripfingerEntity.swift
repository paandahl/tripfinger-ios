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
  
  override init() {}
  
  init(poi: SimplePOI) {
    super.init()
    self.offline = false
    self.name = poi.name
    self.lat = poi.latitude
    self.lon = poi.longitude
    self.type = Int32(Listing.SubCategory(rawValue: poi.subCategory)!.osmType)
  }
  
  init(listing: Listing) {
    self.offline = listing.item().offline
    self.name = listing.item().name
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

  func getFileUrl() -> NSURL {
    return NSURL(string: url, relativeToURL: NSURL.getDirectory(.LibraryDirectory, withPath: "/"))!
  }
}