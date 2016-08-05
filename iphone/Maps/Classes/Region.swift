import Foundation
import RealmSwift

class Region: Object {
  
  // composition (instead of inheritance - for Realm-purposes)
  dynamic var listing: GuideListing!
  dynamic var mwmRegionId: String!
  let draftSizeInBytes = RealmOptional<Int64>()
  let stagedSizeInBytes = RealmOptional<Int64>()
  let publishedSizeInBytes = RealmOptional<Int64>()
  
  func getSizeInBytes() -> Int64 {
    switch TripfingerAppDelegate.mode {
    case .RELEASE:
      return publishedSizeInBytes.value!
    case .BETA:
      return stagedSizeInBytes.value!
    default:
      return draftSizeInBytes.value!      
    }
  }

  // radius
  var radius: Int?
  
  // polygons
  //  var polygonCoordinates: [Double]?
  
  let listings = List<Listing>()
  
  func getDownloadId() -> String {
    if let mwmRegionId = mwmRegionId {
      return mwmRegionId
    } else {
      return getName()
    }
  }
  
  func getCategory() -> Category {
    return Category(rawValue: item().category)!
  }
  
  func setCategory(category: Region.Category) {
    listing.item.category = category.rawValue
  }
  
  enum Category: Int {
    case CONTINENT = 110
    case WORLD_AREA = 120
    case COUNTRY = 130
    case REGION = 140
    case SUB_REGION = 150
    case CITY = 160
    case NEIGHBOURHOOD = 170
    
    var osmType: Int {
      switch self {
      case .COUNTRY:
        return 4252 // country
      default:
        return 4124 // city
      }
    }
  }
  
  
  override static func ignoredProperties() -> [String] {
    return ["offline", "mapCountry", "mapPackage"]
  }
  
  func item() -> GuideItem {
    return listing.item
  }
  
  class func constructRegion(name: String! = nil) -> Region {
    let region = Region()
    region.listing = GuideListing()
    region.listing.item = GuideItem()
    region.listing.item.name = name
    region.listing.item.loadStatus = GuideItem.LoadStatus.CONTENT_NOT_LOADED
    return region
  }
  
  func getSlug() -> String {
    return getName().stringByReplacingOccurrencesOfString("-", withString: "_")
    .stringByReplacingOccurrencesOfString(" ", withString: "-")
  }
}

extension Region: GuideItemHolder {
  
  func getId() -> String! {
    return listing.item.uuid
  }
  
  func getName() -> String {
    return listing.item.name!
  }
}
