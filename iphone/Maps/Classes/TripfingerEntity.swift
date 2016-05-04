import Foundation

//
// Data holder for tripfinger GuideItems, without Realm-dependencies, so that the objects
// can be passed down to the Obj C++-layer
//
@objc public class TripfingerEntity: NSObject {
  
  override init() {}
  
  init(listing: Listing) {
    self.offline = listing.item().offline
    self.name = listing.item().name
    self.lat = listing.listing.latitude
    self.lon = listing.listing.longitude
    self.type = Listing.SubCategory(rawValue: listing.item().subCategory)!.osmType
    self.address = listing.address
    self.website = listing.website
    self.phone = listing.phone
    self.email = listing.email
    
    self.content = listing.item().content
    self.openingHours = listing.openingHours
    self.directions = listing.directions
    self.price = listing.price
    
    if listing.item().images.count > 0 {
      let image = listing.item().images[0]
      self.url = image.url
      self.imageDescription = image.imageDescription
      self.license = image.license
      self.artist = image.artist
      self.originalUrl = image.originalUrl
    }
    if let notes = listing.listing.notes where notes.likedState == GuideListingNotes.LikedState.LIKED  {
      self.liked = true
    }

  }
  
  var offline: Bool!
  var lat: Double = 0
  var lon: Double = 0
  var name: String!
  var identifier: Int!
  var type: Int!
  
  var phone: String!
  var address: String!
  var website: String!
  var email: String!
  
  var content: String!
  var price: String!
  var openingHours: String!
  var directions: String!

  var url: String!
  var imageDescription: String!
  var license: String!
  var artist: String!
  var originalUrl: String!
  
  var liked = false
  
  func getFileUrl() -> NSURL {
    return NSURL(string: url, relativeToURL: NSURL.getDirectory(.LibraryDirectory, withPath: "/"))!
  }
}