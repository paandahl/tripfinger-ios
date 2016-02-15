import Foundation
import RealmSwift

class AttractionSwipe: Object {
 
  dynamic var attractionId: String!
  dynamic var swipeState = 0
 
  enum SwipeState: Int {
    case SWIPED_LEFT = 1
    case SWIPED_RIGHT = 2
  }

}