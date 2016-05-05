import Foundation

//
// Data holder for tripfinger GuideItems, without Realm-dependencies, so that the objects
// can be passed down to the Obj C++-layer
//
@objc public class TripfingerEntity: NSObject {
  
  var offline: Bool!
  var lat: Double = 0
  var lon: Double = 0
  var name: String!
  
  var identifier: Int32 = 0
  var type: Int32 = 0
  
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
  
  static var identifierCount: Int32 = 789000
  static var idMap: [Int32: String] = [Int32: String]()
  
  func putInIdMap(id: String) {
    let annotationId = TripfingerEntity.identifierCount
    TripfingerEntity.identifierCount += 1
    if TripfingerEntity.identifierCount >= 790000 {
      TripfingerEntity.identifierCount = 789000
    }

    TripfingerEntity.idMap[annotationId] = id
    self.identifier = annotationId
  }
  
  override init() {}
  
  init(poi: SimplePOI) {
    super.init()
    self.name = poi.name
    self.lat = poi.latitude
    self.lon = poi.longitude
    self.type = Int32(Listing.SubCategory(rawValue: poi.subCategory)!.osmType)
    putInIdMap(poi.listingId!)
  }
  
  init(listing: Listing) {
    self.offline = listing.item().offline
    self.name = listing.item().name
    self.lat = listing.listing.latitude
    self.lon = listing.listing.longitude
    self.type = Int32(Listing.SubCategory(rawValue: listing.item().subCategory)!.osmType)
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

  func getFileUrl() -> NSURL {
    return NSURL(string: url, relativeToURL: NSURL.getDirectory(.LibraryDirectory, withPath: "/"))!
  }
}