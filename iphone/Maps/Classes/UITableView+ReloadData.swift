import Foundation

extension UITableView {
  func reloadData(completion: ()->()) {
    UIView.animateWithDuration(0, animations: { self.reloadData() })
      { _ in completion() }
  }
}