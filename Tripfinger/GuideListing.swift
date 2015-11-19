import Foundation
import RealmSwift

class GuideListing: Object {
  
  // composition (instead of inheritance - for Realm-purposes)
  dynamic var item: GuideItem!
  
  dynamic var longitude = 0.0
  dynamic var latitude = 0.0
}