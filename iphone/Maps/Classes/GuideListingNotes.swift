import Foundation
import RealmSwift

class GuideListingNotes: Object {
 
  dynamic var attractionId: String!
  dynamic var likedStateId = LikedState.NOT_YET_LIKED_OR_SWIPED.rawValue
  var likedState: LikedState {
    set {
      likedStateId = newValue.rawValue
    }
    get {
      return LikedState(rawValue: likedStateId)!
    }
  }
  
  func swiped() -> Bool {
    return likedStateId != LikedState.NOT_YET_LIKED_OR_SWIPED.rawValue
  }
  
  enum LikedState: Int {
    case NOT_YET_LIKED_OR_SWIPED = 0
    case SWIPED_LEFT = 1
    case LIKED = 2 // swiped right or hearted in list-view
  }

}