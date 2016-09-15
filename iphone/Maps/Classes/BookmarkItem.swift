import Foundation

class BookmarkItem: NSObject {
  
  private static let PROPERTY_NAME = "name"
  private static let PROPERTY_LATITUDE = "latitude"
  private static let PROPERTY_LONGITUDE = "longitude"
  private static let PROPERTY_NOTES = "notes"
  private static let PROPERTY_LISTING_ID = "listingId"

  var databaseKey: String?
  let name: String
  let latitude: Double
  let longitude: Double
  var notes: String?
  var listingId: String?
  
  init(name: String, latitude: Double, longitude: Double) {
    self.name = name
    self.latitude = latitude
    self.longitude = longitude
  }

  init(name: String, latitude: Double, longitude: Double, listingId: String) {
    self.name = name
    self.latitude = latitude
    self.longitude = longitude
    self.listingId = listingId
  }

  init(dict: [String: AnyObject]) {
    self.name = dict[BookmarkItem.PROPERTY_NAME] as! String
    self.latitude = dict[BookmarkItem.PROPERTY_LATITUDE] as! Double
    self.longitude = dict[BookmarkItem.PROPERTY_LONGITUDE] as! Double
    self.notes = dict[BookmarkItem.PROPERTY_NOTES] as? String
    self.listingId = dict[BookmarkItem.PROPERTY_LISTING_ID] as? String
  }
  
  func toDict() -> [String: AnyObject] {
    var dict = [String: AnyObject]()
    dict[BookmarkItem.PROPERTY_NAME] = name
    dict[BookmarkItem.PROPERTY_LATITUDE] = latitude
    dict[BookmarkItem.PROPERTY_LONGITUDE] = longitude
    dict[BookmarkItem.PROPERTY_NOTES] = notes
    dict[BookmarkItem.PROPERTY_LISTING_ID] = listingId
    return dict
  }
}