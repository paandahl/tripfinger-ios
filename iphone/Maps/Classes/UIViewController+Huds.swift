import Foundation
import MBProgressHUD

extension UIViewController {
  
  func showLoadingHud() {
    let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    loadingNotification.mode = MBProgressHUDMode.Indeterminate
    loadingNotification.labelText = "Loading"
  }
  
  func showErrorHud() {
    hideHuds()
    let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    loadingNotification.mode = MBProgressHUDMode.CustomView
    loadingNotification.labelText = "Connection failed"

    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue()) {
      self.hideHuds()
    }
  }
  
  func hideHuds() {
    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
  }
}