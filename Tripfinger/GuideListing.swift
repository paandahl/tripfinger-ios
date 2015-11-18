import Foundation
import RealmSwift

class GuideListing: Object {
  
  // composition (instead of inheritance - for Realm-purposes)
  var item: GuideItem!
  
  var longitude: Double!
  var latitude: Double!
}