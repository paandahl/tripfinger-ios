import Foundation
import RealmSwift

/** Class describing a text-item. Referred to as a GuideSection when listed as a loose child of a GuideItem,
*  and as a CategoryDescription when 'category' is set.
*/
class GuideText: Object {
  
  // composition (instead of inheritance - for Realm-purposes)
  dynamic var item: GuideItem!
}

extension GuideText: GuideItemHolder {
  
  func getId() -> String! {
    return item.uuid
  }
  
  func getName() -> String {
    return item.name!
  }
  
  func getCategory() -> Listing.Category {
    return Listing.Category(rawValue: item.category)!
  }
  
  class func constructCategoryDescription(category: Listing.Category, forRegion region: Region) -> GuideText {
    let catDesc = GuideText()
    catDesc.item = GuideItem()
    catDesc.item.category = category.rawValue
    catDesc.item.name = category.entityName
    catDesc.item.content = nil
    catDesc.item.offline = region.item().offline
    catDesc.item.loadStatus = GuideItem.LoadStatus.FULLY_LOADED
    return catDesc
  }
}
