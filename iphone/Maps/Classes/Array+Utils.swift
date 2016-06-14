import Foundation

extension Array where Element : Equatable {
  
  mutating func removeObject(object : Generator.Element) {
    if let index = self.indexOf(object) {
      self.removeAtIndex(index)
    }
  }
}