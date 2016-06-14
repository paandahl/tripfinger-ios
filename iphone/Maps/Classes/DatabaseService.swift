import Foundation
import RealmSwift
import CoreLocation

class DatabaseService {
  
  static let TFCountrySavedNotification = "TFCountrySavedNotification"
  static let TFCountryUpdatingNotification = "TFCountryUpdatingNotification"
  static let TFCountryDeletedNotification = "TFCountryDeletedNotification"

  
  static var testMode = false
  static var testCounter = 0
  static var mainThreadRealm: Realm!
  
  class func startTestMode() {
    testMode = true
    mainThreadRealm = nil // loose the reference, so that data is cleared from previous test runs
    testCounter += 1
  }

  static func getRealm() -> Realm {
    if NSThread.currentThread().isMainThread {
      if mainThreadRealm == nil {
        if testMode || NSProcessInfo.processInfo().arguments.contains("TEST") {
          print("got in-memory realm")
          mainThreadRealm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "MemoryRealm\(testCounter)"))
        }
        else {
          mainThreadRealm = try! Realm()
        }
      }
      mainThreadRealm.refresh()
      return mainThreadRealm
    }
    else {
      if testMode || NSProcessInfo.processInfo().arguments.contains("TEST") {
        print("got in-memory realm")
        return try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "MemoryRealm\(testCounter)"))
      }
      else {
        return try! Realm()
      }
    }
  }
  
  class func saveLike(likedState: GuideListingNotes.LikedState, listing: Listing, addNativeMarks: Bool = true) {
    
    if likedState == .LIKED && addNativeMarks {
      print("Adding bookmark")
      MapsAppDelegateWrapper.saveBookmark(TripfingerEntity(listing: listing))
    }
    
    let realm = getRealm()
    try! realm.write {
      if let listingNotes = listing.listing.notes {
        if likedState != .LIKED && listingNotes.likedState == .LIKED && addNativeMarks {
          print("Deleting bookmark")
          MapsAppDelegateWrapper.deleteBookmark(TripfingerEntity(listing: listing))
        }
        listingNotes.likedState = likedState
      } else {
        let guideListingNotes = GuideListingNotes()
        guideListingNotes.likedState = likedState
        guideListingNotes.attractionId = listing.item().uuid
        realm.add(guideListingNotes)
        listing.listing.notes = guideListingNotes
      }
    }
  }
  
  class func getListingNotes(listingId: String) -> GuideListingNotes? {
    let predicate = NSPredicate(format: "attractionId = %@", listingId)
    return getRealm().objects(GuideListingNotes).filter(predicate).first
  }
  
  class func saveRegion(region: Region, callback: (Region -> ())? = nil) throws {

    print("Saving region")
    SyncManager.run_async_throws {
      let realm = getRealm()
      let existing = getRegionWithId(region.getId(), writeRealm: realm)
      if let existing = existing {
        if existing.getCategory() == Region.Category.COUNTRY {
          let countryName = existing.getName()
          dispatch_sync(dispatch_get_main_queue()) {
            NSNotificationCenter.defaultCenter().postNotificationName(TFCountryUpdatingNotification, object: countryName)
          }
        }
        deleteRegion(existing, notification: false)
        print("Replacing region: \(region.getId()) in db.")
      }
      
      // Add to the Realm inside a transaction
      try! realm.write {
        realm.add(region)
      }
      region.item().offline = true
      if region.getCategory() == Region.Category.COUNTRY {
        let countryName = region.getName()
        dispatch_sync(dispatch_get_main_queue()) {
          NSNotificationCenter.defaultCenter().postNotificationName(TFCountrySavedNotification, object: countryName)
        }
      }
      if let callback = callback {
        callback(region)
      }
    }
  }
  
  class func getRegionWithId(regionId: String, writeRealm: Realm! = nil) -> Region? {
    let regions = writeRealm != nil ? writeRealm.objects(Region) : getRealm().objects(Region)
    return regions.filter("listing.item.uuid = '\(regionId)'").first
  }

  class func getRegionWithSlug(slug: String) -> Region! {
    return getRealm().objects(Region).filter("listing.item.slug = '\(slug)'").first
  }

  class func getGuideItemWithId(uuid: String) -> GuideItem! {
    return getRealm().objects(GuideItem).filter("uuid = '\(uuid)'").first
  }

  class func getCountries() -> Results<Region> {
    let realm = getRealm()
    realm.refresh()
    return realm.objects(Region).filter("listing.item.category = \(Region.Category.COUNTRY.rawValue)")
  }
  
  class func getCountry(countryName: String) -> Region! {
    return getRealm().objects(Region).filter("listing.item.category = \(Region.Category.COUNTRY.rawValue) and listing.item.name = '\(countryName)'").first
  }

  class func getCountryWithMwmId(mwmRegionId: String) -> Region! {
    let region = getRealm().objects(Region).filter("listing.item.category = \(Region.Category.COUNTRY.rawValue) and mwmRegionId = '\(mwmRegionId)'").first
    if let region = region {
      return region
    } else {
      return getCountry(mwmRegionId)
    }
  }

  class func getSubRegionOrCity(countryName: String, itemName: String) -> Region! {
    return getRealm().objects(Region).filter("(listing.item.category = \(Region.Category.CITY.rawValue) or listing.item.category = \(Region.Category.SUB_REGION.rawValue)) and listing.country = '\(countryName)' and listing.item.name = '\(itemName)'").first
  }


  class func getCity(countryName: String, cityName: String) -> Region! {
    return getRealm().objects(Region).filter("listing.item.category = \(Region.Category.CITY.rawValue) and listing.country = '\(countryName)' and listing.item.name = '\(cityName)'").first
  }

  class func getNeighbourhood(countryName: String, cityName: String, hoodName: String) -> Region! {
    return getRealm().objects(Region).filter("listing.item.category = \(Region.Category.NEIGHBOURHOOD.rawValue) and listing.country = '\(countryName)' and listing.city = '\(cityName)'  and listing.item.name = '\(hoodName)'").first
  }
  
  class func getListingsForRegion(region: Region) -> Results<Listing> {
    let predicate = NSPredicate(format: "listing.item.parent = %@", region.getId())
    return getRealm().objects(Listing).filter(predicate)
  }
  
  class func getCascadingListingsForRegion(region: Region?, category: Int? = nil) -> List<Listing> {
    var predicate: NSPredicate!
    var listings: Results<Listing>!
    if let region = region {
      switch region.item().category {
      case Region.Category.COUNTRY.rawValue:
        predicate = NSPredicate(format: "listing.country = %@", region.item().name)
      case Region.Category.SUB_REGION.rawValue:
        predicate = NSPredicate(format: "listing.country = %@ and listing.subRegion = %@", region.listing.country!, region.item().name)
      case Region.Category.CITY.rawValue:
        predicate = NSPredicate(format: "listing.country = %@ and listing.city = %@", region.listing.country!, region.item().name)
      case Region.Category.NEIGHBOURHOOD.rawValue:
        predicate = NSPredicate(format: "listing.item.parent = %@", region.item().uuid)
      default:
        try! { throw Error.RuntimeError("Cascade not supported for type: \(region.item().category)") }()
      }
      listings = getRealm().objects(Listing).filter(predicate)
    }
    else {
      listings = getRealm().objects(Listing)
    }
    if let category = category {
      let categoryPredicate: NSPredicate
      if (String(category).characters.count == 3) {
        print("Filtering by category: \(category)")
        categoryPredicate = NSPredicate(format: "listing.item.category = %d", category)
      } else {
        print("Filtering by subcategory: \(category)")
        categoryPredicate = NSPredicate(format: "listing.item.subCategory = %d", category)
      }
      listings = listings.filter(categoryPredicate)
    }
    let list = List<Listing>()
    for attraction in listings {
      if attraction.listing.latitude != 0 && attraction.listing.longitude != 0 {
        list.append(attraction)
      }
    }
    return list
  }

  class func getListingWithId(attractionId: String) -> Listing? {
    let predicate = NSPredicate(format: "listing.item.uuid = %@", attractionId)
    let attractions = getRealm().objects(Listing).filter(predicate)
    print("got \(attractions.count) attractions with id \(attractionId)")
    if attractions.count == 1 {
      return attractions[0]
    }
    else {
      return nil
    }
  }
  class func getListingWithSlug(slug: String) -> Listing? {
    let predicate = NSPredicate(format: "listing.item.slug = %@", slug)
    let listings = getRealm().objects(Listing).filter(predicate)
    print("got \(listings.count) attractions with id \(slug)")
    if listings.count == 1 {
      return listings[0]
    }
    else {
      return nil
    }
  }

  
  class func getListingByCoordinate(coord: CLLocationCoordinate2D) -> Listing? {
    let realm = getRealm()
    let margin = 0.0000005
    let minCoord = CLLocationCoordinate2DMake(coord.latitude - margin, coord.longitude - margin)
    let maxCoord = CLLocationCoordinate2DMake(coord.latitude + margin, coord.longitude + margin)
    print("fetching listing by coordinate")
    print("latitude \(minCoord.latitude) > < \(maxCoord.latitude)")
    print("longitude \(minCoord.latitude) > < \(maxCoord.latitude)")
    let attraction = realm.objects(Listing).filter("listing.latitude > \(minCoord.latitude) and listing.latitude < \(maxCoord.latitude) and listing.longitude > \(minCoord.longitude)  and listing.longitude < \(maxCoord.longitude)").first
    return attraction
  }
  
  class func getPois(bottomLeft: CLLocationCoordinate2D, topRight: CLLocationCoordinate2D, zoomLevel: Int) -> [Listing] {
    let realm = getRealm()
    let listings = realm.objects(Listing).filter("listing.latitude > \(bottomLeft.latitude) and listing.latitude < \(topRight.latitude) and listing.longitude > \(bottomLeft.longitude)  and listing.longitude < \(topRight.longitude)")
    return Array(listings)
  }
  
  class func getPois(bottomLeft: CLLocationCoordinate2D, topRight: CLLocationCoordinate2D, category: Int) -> [Listing] {
    let realm = getRealm()
    let listings = realm.objects(Listing).filter("listing.latitude > \(bottomLeft.latitude) and listing.latitude < \(topRight.latitude) and listing.longitude > \(bottomLeft.longitude)  and listing.longitude < \(topRight.longitude) and listing.item.category = \(category)")
    return Array(listings)
  }  
  
  class func search(query: String, callback: List<SimplePOI> -> ()) {
    dispatch_async(dispatch_get_main_queue()) {
      let results = List<SimplePOI>()
      let realm = getRealm()

      let listings = realm.objects(GuideListing).filter("item.name contains[c] '\(query)'")
      print("got \(listings.count) listings")
      for listing in listings {
        let poi = SimplePOI(listing: listing)
        results.append(poi)
      }
    
      callback(results)
    }
  }
  
  class func deleteGuideText(guideText: GuideText) {
    for section in guideText.item.guideSections {
      deleteGuideText(section)
    }
    
    let realm = getRealm()
    try! realm.write {
      realm.delete(guideText)
    }
  }
  
  class func deleteListing(listing: Listing) {
    let realm = getRealm()
    try! realm.write {
      realm.delete(listing)
    }
  }
  
  class func deleteRegion(region: Region, notification: Bool = true) {
    
    if notification && region.getCategory() == Region.Category.COUNTRY {
      NSNotificationCenter.defaultCenter().postNotificationName(TFCountryDeletedNotification, object: region.getName())
    }
    for subRegion in region.item().subRegions {
      deleteRegion(subRegion)
    }
    
    for section in region.item().guideSections {
      deleteGuideText(section)
    }

    for categoryDescription in region.item().categoryDescriptions {
      deleteGuideText(categoryDescription)
    }
    
    let listings = getListingsForRegion(region)
    for listing in listings {
      deleteListing(listing)
    }

    let realm = getRealm()
    try! realm.write {
      realm.delete(region)
    }
  }
  
  class func deleteCountry(name: String) {
    let country = getCountry(name)
    if let country = country {
      deleteRegion(country)
    }
  }

  class func getCitiesInCountry(country: String) -> Results<Region> {
    return getRealm().objects(Region).filter("listing.item.category = \(Region.Category.CITY.rawValue) and listing.country = '\(country)'")
  }

  class func getRegionsWithParent(parentId: String) -> Results<Region> {
    return getRealm().objects(Region).filter("listing.item.parent = \"\(parentId)\"")
  }
  
  class func getGuideTextWithId(guideTextId: String) -> GuideText? {
    let predicate = NSPredicate(format: "item.uuid = %@", guideTextId)
    return getRealm().objects(GuideText).filter(predicate).first
  }
  
  class func getCoordinateSet() -> Set<Int64> {
    var coordinateSet = Set<Int64>()
    let listings = getRealm().objects(Listing)
    for listing in listings {
      coordinateSet.insert(TripfingerAppDelegate.coordinateToInt(CLLocationCoordinate2DMake(listing.listing.latitude, listing.listing.longitude)))
    }
    return coordinateSet
  }
  
  class func addDownloadMarker(mwmRegionId: String) {
    if hasDownloadMarker(mwmRegionId) {
      return
    }
    let realm = getRealm()
    try! realm.write {
      let marker = DownloadMarker()
      marker.country = mwmRegionId
      marker.timeAdded = NSDate().timeIntervalSince1970
      realm.add(marker)
    }
  }
  
  class func removeDownloadMarker(mwmRegionId: String) {
    let realm = getRealm()
    let marker = realm.objects(DownloadMarker).filter("country = \"\(mwmRegionId)\"").first
    try! realm.write {
      if let marker = marker {
        realm.delete(marker)        
      }
    }
  }
  
  class func hasDownloadMarker(mwmRegionId: String) -> Bool {
    let realm = getRealm()
    let markers = realm.objects(DownloadMarker).filter("country = \"\(mwmRegionId)\"")
    return markers.count > 0
  }
  
  class func isDownloadMarkerCancelled(mwmRegionId: String) -> Bool {
    let realm = getRealm()
    let marker = realm.objects(DownloadMarker).filter("country = \"\(mwmRegionId)\"").first
    if let marker = marker {
      return marker.cancelled
    } else {
      return true
    }
  }
  
  class func setCancelledOnDownloadMarker(mwmRegionId: String) {
    let realm = getRealm()
    let marker = realm.objects(DownloadMarker).filter("country = \"\(mwmRegionId)\"").first
    try! realm.write {
      if let marker = marker {
        marker.cancelled = true
      }
    }
  }
  
  class func getCountriesWithDownloadMarkers() -> Results<DownloadMarker> {
    let realm = getRealm()
    return realm.objects(DownloadMarker)
  }
}