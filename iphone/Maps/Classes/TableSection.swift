import Foundation

class TableSection {
  var title: String?
  var cellIdentifier: String
  var elements = [(String, AnyObject)]()
  var handler: (AnyObject -> ())?
  
  init(title: String? = nil, cellIdentifier: String, handler: (AnyObject -> ())?) {
    self.title = title
    self.cellIdentifier = cellIdentifier
    self.handler = handler
  }
}
