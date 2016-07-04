import Foundation

class TableSection: NSObject {
  var title: String?
  var cellIdentifier: String
  var elements = [(String, AnyObject)]()
  var handler: (AnyObject -> ())?
  
  init(title: String? = nil, cellIdentifier: String) {
    self.title = title
    self.cellIdentifier = cellIdentifier
    self.handler = nil
  }

  init(title: String? = nil, cellIdentifier: String, target: NSObject, selector: Selector) {
    self.title = title
    self.cellIdentifier = cellIdentifier
    super.init()
    self.handler = { [weak target] value in
      if let target = target {
        target.performSelectorOnMainThread(selector, withObject: value, waitUntilDone: false)
      }
    }
  }
}
