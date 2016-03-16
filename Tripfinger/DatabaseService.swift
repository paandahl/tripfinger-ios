import Foundation
import RealmSwift

class DatabaseService {
  
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
          print("got disk realm")
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
        print("got disk realm")
        return try! Realm()
      }
    }
  }
  
  class func saveLike(likedState: GuideListingNotes.LikedState, attraction: Attraction) {
    let guideListingNotes = GuideListingNotes()
    guideListingNotes.likedState = likedState
    guideListingNotes.attractionId = attraction.item().id
    let realm = getRealm()
    try! realm.write {
      realm.add(guideListingNotes)
      attraction.listing.notes = guideListingNotes
    }
  }
  
  class func getAttractionNotes(attractionId: String) -> GuideListingNotes? {
    let predicate = NSPredicate(format: "attractionId = %@", attractionId)
    return getRealm().objects(GuideListingNotes).filter(predicate).first
  }
  
  class func saveRegion(region: Region, callback: (Region -> ())? = nil) throws {

    print("Saving region")
    SyncManager.run_async_throws {
      print("Saving region2")
      let realm = getRealm()
      let existing = getRegionWithId(region.getId(), writeRealm: realm)
      if existing != nil {
        throw Error.RuntimeError("Reagion with id \(region.getId()) already exists in db.")
      }
      
      // Add to the Realm inside a transaction
      try! realm.write {
        realm.add(region)
      }
      if let callback = callback {
        callback(region)
      }
    }
  }
  
  class func getRegionWithId(regionId: String, writeRealm: Realm! = nil) -> Region? {
    let regions = writeRealm != nil ? writeRealm.objects(Region) : getRealm().objects(Region)

    for region in regions {
      if region.listing.item.id == regionId {
        region.item().offline = true
        return region
      }
    }
    return nil
  }
    
  class func getCountries() -> Results<Region> {
    let realm = getRealm()
    realm.refresh()
    return realm.objects(Region).filter("listing.item.category = \(Region.Category.COUNTRY.rawValue)")
  }
  
  class func getCountry(countryName: String) -> Region! {
    return getRealm().objects(Region).filter("listing.item.category = \(Region.Category.COUNTRY.rawValue) and listing.item.name = '\(countryName)'").first
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
  
  class func getAttractionsForRegion(region: Region) -> Results<Attraction> {
    let predicate = NSPredicate(format: "listing.item.parent = %@", region.getId())
    return getRealm().objects(Attraction).filter(predicate)
  }
  
  class func getCascadingAttractionsForRegion(region: Region?, category: Attraction.Category? = nil) -> List<Attraction> {
    var predicate: NSPredicate!
    var attractions: Results<Attraction>!
    if let region = region {
      switch region.item().category {
      case Region.Category.COUNTRY.rawValue:
        predicate = NSPredicate(format: "listing.country = %@", region.item().name)
      case Region.Category.SUB_REGION.rawValue:
        predicate = NSPredicate(format: "listing.country = %@ and listing.subRegion = %@", region.listing.country, region.item().name)
      case Region.Category.CITY.rawValue:
        predicate = NSPredicate(format: "listing.country = %@ and listing.city = %@", region.listing.country, region.item().name)
      case Region.Category.NEIGHBOURHOOD.rawValue:
        predicate = NSPredicate(format: "listing.parent = %@", region.item().id)
      default:
        try! { throw Error.RuntimeError("Cascade not supported for type: \(region.item().category)") }()
      }
      attractions = getRealm().objects(Attraction).filter(predicate)
    }
    else {
      attractions = getRealm().objects(Attraction)
    }
    if let category = category {
      print("Filtering by category: \(category.rawValue)")
      let categoryPredicate = NSPredicate(format: "listing.item.category = %d", category.rawValue)
      attractions = attractions.filter(categoryPredicate)
    }
    let list = List<Attraction>()
    for attraction in attractions {
      if attraction.item().images.count > 0 && attraction.listing.latitude != 0 && attraction.listing.longitude != 0 {
        list.append(attraction)
      }
    }
    return list
  }

  class func getAttractionWithId(attractionId: String) -> Attraction? {
    let predicate = NSPredicate(format: "listing.item.id = %@", attractionId)
    let attractions = getRealm().objects(Attraction).filter(predicate)
    print("got \(attractions.count) attractions with id \(attractionId)")
    if attractions.count == 1 {
      return attractions[0]
    }
    else {
      return nil
    }
  }
  
  class func getPois(bottomLeft: CLLocationCoordinate2D, topRight: CLLocationCoordinate2D, zoomLevel: Int, category: Attraction.Category) -> List<SimplePOI> {
    let realm = getRealm()
    let attractions = realm.objects(Attraction).filter("listing.latitude > \(bottomLeft.latitude) and listing.latitude < \(topRight.latitude) and listing.longitude > \(bottomLeft.longitude)  and listing.longitude < \(topRight.longitude) and listing.item.category = \(category.rawValue)")
    let simplePois = realm.objects(SimplePOI).filter("latitude > \(bottomLeft.latitude) and latitude < \(topRight.latitude) and longitude > \(bottomLeft.longitude)  and longitude < \(topRight.longitude)")

    let results = List<SimplePOI>()
    for attraction in attractions {
      let poi = SimplePOI(listing: attraction.listing)
      results.append(poi)
    }
    results.appendContentsOf(simplePois)
    return results
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
      
      let pois = realm.objects(SimplePOI).filter("name contains[c] '\(query)'")
      print("got \(pois.count) pois")
      for poi in pois {
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
  
  class func deleteAttraction(attraction: Attraction) {
    let realm = getRealm()
    try! realm.write {
      realm.delete(attraction)
    }
  }
  
  class func deleteRegion(region: Region) {
    
    for subRegion in region.item().subRegions {
      deleteRegion(subRegion)
    }
    
    for section in region.item().guideSections {
      deleteGuideText(section)
    }

    for categoryDescription in region.item().categoryDescriptions {
      deleteGuideText(categoryDescription)
    }
    
    let attractions = getAttractionsForRegion(region)
    for attraction in attractions {
      deleteAttraction(attraction)
    }

    let realm = getRealm()
    try! realm.write {
      realm.delete(region)
    }
  }
  
  class func deleteCountry(name: String) {
    let country = getCountry(name)
    deleteRegion(country)
  }

  class func getCitiesInCountry(country: String) -> Results<Region> {
    return getRealm().objects(Region).filter("listing.item.category = \(Region.Category.CITY.rawValue) and listing.country = '\(country)'")
  }

  class func getRegionsWithParent(parentId: String) -> Results<Region> {
    return getRealm().objects(Region).filter("listing.item.parent = \"\(parentId)\"")
  }
  
  class func getGuideTextWithId(region: Region, guideTextId: String) -> GuideText {
    let predicate = NSPredicate(format: "item.id = %@", guideTextId)
    let guideTexts = getRealm().objects(GuideText).filter(predicate)
    return guideTexts[0]
  }
}