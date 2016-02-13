import Foundation
import RealmSwift

class DatabaseService {
  
  static var testMode = false
  static var mainThreadRealm: Realm!
  
  class func startTestMode() {
    testMode = true
    getRealm()
  }
  
  static func getRealm() -> Realm {
    if NSThread.currentThread().isMainThread {
      if mainThreadRealm == nil {
        if testMode {          
          mainThreadRealm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "MyInMemoryRealm"))
        }
        else {
          mainThreadRealm = try! Realm()
        }
      }
      return mainThreadRealm
    }
    else {
      if testMode {
        return try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "MyInMemoryRealm"))
      }
      else {
        return try! Realm()        
      }
    }
  }
  
  class func saveRegion(region: Region, callback: (Region -> ())? = nil) throws {

    SyncManager.run_async_throws {
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
        region.offline = true
        return region
      }
    }
    return nil
  }
    
  class func getCountries() -> Results<Region> {
    return getRealm().objects(Region).filter("listing.item.category = \(Region.Category.COUNTRY.rawValue)")
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
    return getRealm().objects(Attraction).filter("listing.item.parent = '\(region.getId())'")
  }

  class func getAttractionWithId(attractionId: String) -> Attraction? {
    let attractions = getRealm().objects(Attraction).filter("listing.item.id = '\(attractionId)'")
    print("got \(attractions.count) attractions with id \(attractionId)")
    if attractions.count == 1 {
      return attractions[0]
    }
    else {
      return nil
    }
  }
  
  class func getPois(bottomLeft: CLLocationCoordinate2D, topRight: CLLocationCoordinate2D, zoomLevel: Int) -> List<SimplePOI> {
    let realm = getRealm()
    let attractions = realm.objects(Attraction).filter("listing.latitude > \(bottomLeft.latitude) and listing.latitude < \(topRight.latitude) and listing.longitude > \(bottomLeft.longitude)  and listing.longitude < \(topRight.longitude)")
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
  
  class func deleteRegion(countryName: String, cityName: String! = nil) {
    let realm = getRealm()
    try! realm.write {
      if cityName != nil {
        let region = getCity(countryName, cityName: cityName)
        realm.delete(region!)
      }
      else {
        if let region = getCountry(countryName) {
          realm.delete(region)
        }
      }
    }
  }

  class func getCitiesInCountry(country: String) -> Results<Region> {
    return getRealm().objects(Region).filter("listing.item.category = \(Region.Category.CITY.rawValue) and listing.country = '\(country)'")
  }

  class func getRegionsWithParent(parentId: String) -> Results<Region> {
    return getRealm().objects(Region).filter("listing.item.parent = '\(parentId)'")
  }
  
  class func getGuideTextWithId(region: Region, guideTextId: String) -> GuideText {
    let guideTexts = getRealm().objects(GuideText).filter("item.id = '\(guideTextId)'")
    return guideTexts[0]
  }
}