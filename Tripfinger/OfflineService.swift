import Foundation
import RealmSwift

class OfflineService {
  
  static let realm = try! Realm()
  static var writeRealm: Realm!
  
  class func saveRegion(region: Region) throws {

    if writeRealm == nil {
      writeRealm = try! Realm()
    }
    
    let existing = getRegionWithId(region.getId(), writeRealm: writeRealm)
    if existing != nil {
      throw Error.RuntimeError("Reagion with id \(region.getId()) already exists in db.")
    }
    
    // Add to the Realm inside a transaction
    try! writeRealm.write {
      writeRealm.add(region)
    }
  }
  
  class func getRegionWithId(regionId: String, writeRealm: Realm! = nil) -> Region? {
    let regions = writeRealm != nil ? writeRealm.objects(Region) : realm.objects(Region)

    for region in regions {
      if region.listing.item.id == regionId {
        region.offline = true
        return region
      }
    }
    return nil
  }
  
  class func getCountries() -> Results<Region> {
    return realm.objects(Region).filter("listing.item.category = \(Region.Category.COUNTRY.rawValue)")
  }
  
  class func getCountry(countryName: String) -> Region! {
    return realm.objects(Region).filter("listing.item.category = \(Region.Category.COUNTRY.rawValue) and listing.item.name = '\(countryName)'").first
  }

  class func getCity(countryName: String, cityName: String) -> Region! {
    return realm.objects(Region).filter("listing.item.category = \(Region.Category.CITY.rawValue) and listing.country = '\(countryName)' and listing.item.name = '\(cityName)'").first
  }

  class func getNeighbourhood(countryName: String, cityName: String, hoodName: String) -> Region! {
    return realm.objects(Region).filter("listing.item.category = \(Region.Category.NEIGHBOURHOOD.rawValue) and listing.country = '\(countryName)' and listing.city = '\(cityName)'  and listing.item.name = '\(hoodName)'").first
  }

  class func getAttractionWithId(attractionId: String) -> Attraction? {
    let attractions = realm.objects(Attraction).filter("listing.item.id = '\(attractionId)'")
    print("got \(attractions.count) attractions with id \(attractionId)")
    if attractions.count == 1 {
      return attractions[0]
    }
    else {
      return nil
    }
  }
  
  class func getPois(bottomLeft: CLLocationCoordinate2D, topRight: CLLocationCoordinate2D, zoomLevel: Int) -> List<SimplePOI> {
    let attractions = realm.objects(Attraction).filter("listing.latitude > \(bottomLeft.latitude) and listing.latitude < \(topRight.latitude) and listing.longitude > \(bottomLeft.longitude)  and listing.longitude < \(topRight.longitude)")

    let results = List<SimplePOI>()
    for attraction in attractions {
      let poi = SimplePOI(listing: attraction.listing)
      results.append(poi)
    }
    return results
  }
  
  class func deleteRegion(countryName: String, cityName: String! = nil) {
    try! realm.write {
      if cityName != nil {
        let region = getCity(countryName, cityName: cityName)
        realm.delete(region!)
      }
      else {
        let region = getCountry(countryName)
        realm.delete(region!)
      }
    }
  }

  class func getCitiesInCountry(country: String) -> Results<Region> {
    return realm.objects(Region).filter("listing.item.category = \(Region.Category.CITY.rawValue) and listing.country = '\(country)'")
  }

  class func getRegionsWithParent(parentId: String) -> Results<Region> {
    return realm.objects(Region).filter("listing.item.parent = '\(parentId)'")
  }
  
  class func getGuideTextWithId(region: Region, guideTextId: String) -> GuideText {
    let guideTexts = realm.objects(GuideText).filter("item.id = '\(guideTextId)'")
    return guideTexts[0]
  }
}