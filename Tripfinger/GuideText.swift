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
  
  func getId() -> String {
    return item.id
  }
  
  func getName() -> String {
    return item.name!
  }
}
