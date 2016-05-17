import Foundation
import RealmSwift

class DownloadMarker: Object {
  
  dynamic var country: String!
  dynamic var timeAdded = 0.0
  dynamic var cancelled = false
}
