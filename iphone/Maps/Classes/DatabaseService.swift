import Foundation
import RealmSwift
import CoreLocation

class DatabaseService {
  
  static let TFCountrySavedNotification = "TFCountrySavedNotification"
  static let TFCountryUpdatingNotification = "TFCountryUpdatingNotification"
  static let TFCountryDeletingNotification = "TFCountryDeletingNotification"
  static let TFCountryDeletedNotification = "TFCountryDeletedNotification"
  static let TFLikedStatusChangedNotification = "TFLikedStatusChangedNotification"

  
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

  class func saveLinkeInMwmAndTf(likedState: GuideListingNotes.LikedState, entity: TripfingerEntity) {
    saveLikeInMwm(likedState, entity: entity)
    saveLikeInTf(likedState, listingId: entity.tripfingerId)
    entity.liked = likedState == GuideListingNotes.LikedState.LIKED
  }

  class func saveLinkeInMwmAndTf(likedState: GuideListingNotes.LikedState, listing: Listing) {
    saveLikeInMwm(likedState, entity: TripfingerEntity(listing: listing))
    saveLikeInTf(likedState, listingId: listing.item().uuid)
    listing.listing.notes = getListingNotes(listing.item().uuid)
  }

  class func saveLikeInMwm(likedState: GuideListingNotes.LikedState, entity: TripfingerEntity) {
    if likedState == .LIKED {
      MapsAppDelegateWrapper.saveBookmark(entity)
    } else if let listingNotes = DatabaseService.getAttachedListingNotes(entity.tripfingerId) {
      if likedState != .LIKED && listingNotes.likedState == .LIKED {
        MapsAppDelegateWrapper.deleteBookmark(entity)
      }
    }
  }
  
  class func saveLikeInTf(likedState: GuideListingNotes.LikedState, listingId: String) {
    if let listingNotes = getAttachedListingNotes(listingId) {
      let realm = listingNotes.realm!
      try! realm.write {
        listingNotes.likedState = likedState
      }
      // to fix disconnected ones from earlier bugs
      if let listing = DatabaseService.getAttachedListingWithId(listingId) {
        try! listing.realm!.write {
          listing.listing.notes = listingNotes
        }
      }
    } else {
      let offlineListing = getAttachedListingWithId(listingId)
      let realm = offlineListing?.realm! ?? getRealm()
      try! realm.write {
        let guideListingNotes = GuideListingNotes()
        guideListingNotes.likedState = likedState
        guideListingNotes.attractionId = listingId
        realm.add(guideListingNotes)
        offlineListing?.listing.notes = guideListingNotes
      }
    }
    dispatch_async(dispatch_get_main_queue()) {
      NSNotificationCenter.defaultCenter().postNotificationName(TFLikedStatusChangedNotification, object: listingId)
    }
  }

  private class func getAttachedListingNotes(listingId: String) -> GuideListingNotes? {
    let predicate = NSPredicate(format: "attractionId = %@", listingId)
    return getRealm().objects(GuideListingNotes).filter(predicate).first
  }

  class func getListingNotes(listingId: String) -> GuideListingNotes? {
    let listingNotes = getAttachedListingNotes(listingId)
    return detachListingNotes(listingNotes)
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

  private class func getAttachedRegionWithId(regionId: String, writeRealm: Realm? = nil) -> Region? {
    let regions: Results<Region>
    if let writeRealm = writeRealm {
      regions = writeRealm.objects(Region)
    } else {
      regions = getRealm().objects(Region)
    }
    return regions.filter("listing.item.uuid = '\(regionId)'").first
  }

  class func getRegionWithId(regionId: String, writeRealm: Realm! = nil) -> Region? {
    let region = getAttachedRegionWithId(regionId, writeRealm: writeRealm)
    return detachRegion(region)
  }

  class func getRegionWithSlug(slug: String) -> Region? {
    let region = getRealm().objects(Region).filter("listing.item.slug = '\(slug)'").first
    return detachRegion(region)
  }

  class func getCountries() -> [Region] {
    let realm = getRealm()
    realm.refresh()
    let results = realm.objects(Region).filter("listing.item.category = \(Region.Category.COUNTRY.rawValue)")
    return detachRegions(results)
  }
  
  class func getCountry(countryName: String) -> Region? {
    let country = getRealm().objects(Region).filter("listing.item.category = \(Region.Category.COUNTRY.rawValue) and listing.item.name = '\(countryName)'").first
    return detachRegion(country)
  }

  class func getCountryWithMwmId(mwmRegionId: String) -> Region? {
    let region = getRealm().objects(Region).filter("listing.item.category = \(Region.Category.COUNTRY.rawValue) and mwmRegionId = '\(mwmRegionId)'").first
    if let region = region {
      return detachRegion(region)
    } else {
      return getCountry(mwmRegionId)
    }
  }

  class func getSubRegionOrCity(countryName: String, itemName: String) -> Region? {
    let region = getRealm().objects(Region).filter("(listing.item.category = \(Region.Category.CITY.rawValue) or listing.item.category = \(Region.Category.SUB_REGION.rawValue)) and listing.country = '\(countryName)' and listing.item.name = '\(itemName)'").first
    return detachRegion(region)
  }


  class func getCity(countryName: String, cityName: String) -> Region? {
    let city = getRealm().objects(Region).filter("listing.item.category = \(Region.Category.CITY.rawValue) and listing.country = '\(countryName)' and listing.item.name = '\(cityName)'").first
    return detachRegion(city)
  }

  class func getNeighbourhood(countryName: String, cityName: String, hoodName: String) -> Region? {
    let hood = getRealm().objects(Region).filter("listing.item.category = \(Region.Category.NEIGHBOURHOOD.rawValue) and listing.country = '\(countryName)' and listing.city = '\(cityName)'  and listing.item.name = '\(hoodName)'").first
    return detachRegion(hood)
  }
  
  class func getListingsForRegion(region: Region) -> [Listing] {
    let predicate = NSPredicate(format: "listing.item.parent = %@", region.getId())
    let listings = getRealm().objects(Listing).filter(predicate)
    return detachListings(listings)
  }
  
  class func getCascadingListingsForRegion(region: Region?, category: Int? = nil) -> [Listing] {
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
    var list = [Listing]()
    for listing in listings {
      if listing.listing.latitude != 0 && listing.listing.longitude != 0 {
        list.append(detachListing(listing)!)
      }
    }
    return list
  }
  
  private class func getAttachedListingWithId(attractionId: String) -> Listing? {
    let predicate = NSPredicate(format: "listing.item.uuid = %@", attractionId)
    return getRealm().objects(Listing).filter(predicate).first
  }

  class func getListingWithId(attractionId: String) -> Listing? {
    let listing = getAttachedListingWithId(attractionId)
    return detachListing(listing)
  }
  class func getListingWithSlug(slug: String) -> Listing? {
    let predicate = NSPredicate(format: "listing.item.slug = %@", slug)
    let listings = getRealm().objects(Listing).filter(predicate)
    return detachListing(listings.first)
  }

  class func getListingByCoordinate(coord: CLLocationCoordinate2D) -> Listing? {
    let realm = getRealm()
    let margin = 0.0000005
    let minCoord = CLLocationCoordinate2DMake(coord.latitude - margin, coord.longitude - margin)
    let maxCoord = CLLocationCoordinate2DMake(coord.latitude + margin, coord.longitude + margin)
    let listing = realm.objects(Listing).filter("listing.latitude > \(minCoord.latitude) and listing.latitude < \(maxCoord.latitude) and listing.longitude > \(minCoord.longitude)  and listing.longitude < \(maxCoord.longitude)").first
    return detachListing(listing)
  }
  
  class func getPois(bottomLeft: CLLocationCoordinate2D, topRight: CLLocationCoordinate2D, zoomLevel: Int) -> [Listing] {
    let realm = getRealm()
    let listings = realm.objects(Listing).filter("listing.latitude > \(bottomLeft.latitude) and listing.latitude < \(topRight.latitude) and listing.longitude > \(bottomLeft.longitude)  and listing.longitude < \(topRight.longitude)")
    return detachListings(listings)
  }
  
  class func getPois(bottomLeft: CLLocationCoordinate2D, topRight: CLLocationCoordinate2D, category: Int) -> [Listing] {
    let realm = getRealm()
    let listings = realm.objects(Listing).filter("listing.latitude > \(bottomLeft.latitude) and listing.latitude < \(topRight.latitude) and listing.longitude > \(bottomLeft.longitude)  and listing.longitude < \(topRight.longitude) and listing.item.category = \(category)")
    return detachListings(listings)
  }
  
  class func search(query: String, callback: [SimplePOI] -> ()) {
    dispatch_async(dispatch_get_main_queue()) {
      var results = [SimplePOI]()
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
  
  class func deleteGuideText(guideTextToDelete: GuideText) {
    let guideText = getAttachedGuideTextWithId(guideTextToDelete.getId())!
    for section in guideText.item.guideSections {
      deleteGuideText(section)
    }
    
    let realm = guideText.realm!
    try! realm.write {
      realm.delete(guideText)
    }
  }
  
  class func deleteListing(listingToDelete: Listing) {
    let listing = getAttachedListingWithId(listingToDelete.item().uuid)!
    let realm = listing.realm!
    try! realm.write {
      realm.delete(listing)
    }
  }
  
  class func deleteRegion(regionToDelete: Region, notification: Bool = true) {
    
    let region = getAttachedRegionWithId(regionToDelete.getId())!
    let regionCategory = region.getCategory()
    let regionName = region.getName()
    if notification && regionCategory == Region.Category.COUNTRY {
      NSNotificationCenter.defaultCenter().postNotificationName(TFCountryDeletingNotification, object: regionName)
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

    let realm = region.realm!
    try! realm.write {
      realm.delete(region)
    }
    if notification && regionCategory == Region.Category.COUNTRY {
      NSNotificationCenter.defaultCenter().postNotificationName(TFCountryDeletedNotification, object: regionName)
    }
  }
  
  class func deleteCountry(name: String) {
    let country = getCountry(name)
    if let country = country {
      deleteRegion(country)
    }
  }

  class func getCitiesInCountry(country: String) -> [Region] {
    let cities = getRealm().objects(Region).filter("listing.item.category = \(Region.Category.CITY.rawValue) and listing.country = '\(country)'")
    return detachRegions(cities)
  }

  class func getRegionsWithParent(parentId: String) -> [Region] {
    let regions = getRealm().objects(Region).filter("listing.item.parent = \"\(parentId)\"")
    return detachRegions(regions)
  }

  private class func getAttachedGuideTextWithId(guideTextId: String) -> GuideText? {
    let predicate = NSPredicate(format: "item.uuid = %@", guideTextId)
    return getRealm().objects(GuideText).filter(predicate).first
  }

  class func getGuideTextWithId(guideTextId: String) -> GuideText? {
    let guideText = getAttachedGuideTextWithId(guideTextId)
    return detachGuideText(guideText)
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
  
  class func getCountriesWithDownloadMarkers() -> [DownloadMarker] {
    let realm = getRealm()
    let downloadMarkers = realm.objects(DownloadMarker)
    return detachDownloadMarkers(downloadMarkers)
  }
  
  // MARK: Functions to detach models from Realm
  
  private class func detachRegions(results: Results<Region>) -> [Region] {
    var regions = [Region]()
    for result in results {
      regions.append(detachRegion(result)!)
    }
    return regions
  }
  
  private class func detachRegion(region: Region?) -> Region? {
    guard let region = region else {
      return nil
    }
    let detachedRegion = Region(value: region)
    detachedRegion.listing = detachGuideListing(detachedRegion.listing)
    return detachedRegion
 }
  
  private class func detachListings(results: Results<Listing>) -> [Listing] {
    var listings = [Listing]()
    for result in results {
      listings.append(detachListing(result)!)
    }
    return listings
  }
  
  private class func detachListing(listing: Listing?) -> Listing? {
    guard let listing = listing else {
      return nil
    }
    let detachedListing = Listing(value: listing)
    detachedListing.listing = detachGuideListing(detachedListing.listing)
    return detachedListing
  }
  
  private class func detachListingNotes(listingNotes: GuideListingNotes?) -> GuideListingNotes? {
    guard let listingNotes = listingNotes else {
      return nil
    }
    return GuideListingNotes(value: listingNotes)
  }
  
  private class func detachGuideText(guideText: GuideText?) -> GuideText? {
    guard let guideText = guideText else {
      return nil
    }
    let detachedGuideText = GuideText(value: guideText)
    detachedGuideText.item = detachGuideItem(guideText.item)
    return detachedGuideText
  }
  
  private class func detachGuideListing(guideListing: GuideListing) -> GuideListing {
    let detachedGuideListing = GuideListing(value: guideListing)
    if let notes = detachedGuideListing.notes {
      detachedGuideListing.notes = GuideListingNotes(value: notes)
    }
    detachedGuideListing.item = detachGuideItem(detachedGuideListing.item)
    return detachedGuideListing
  }
  
  private class func detachGuideItem(guideItem: GuideItem) -> GuideItem {
    let detachedGuideItem = GuideItem(value: guideItem)
    let detachedImages = List<GuideItemImage>()
    for image in detachedGuideItem.images {
      detachedImages.append(GuideItemImage(value: image))
    }
    detachedGuideItem.images = detachedImages
    return detachedGuideItem
  }
  
  private class func detachDownloadMarkers(results: Results<DownloadMarker>) -> [DownloadMarker] {
    var markers = [DownloadMarker]()
    for result in results {
      markers.append(DownloadMarker(value: result))
    }
    return markers
  }
}