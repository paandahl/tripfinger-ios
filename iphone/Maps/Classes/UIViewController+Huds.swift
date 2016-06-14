import Foundation
import MBProgressHUD

extension UIViewController {
  
  func addObserver(name: String, selector: Selector) {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: name, object: nil)
  }
  
  func delay(delay: Double, selector: Selector) {
    NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(delay), target: self, selector: selector, userInfo: nil, repeats: false)
  }
  
  func showLoadingHud() {
    print("disabling user interac")
    self.navigationController!.view.userInteractionEnabled = false
    let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    loadingNotification.mode = MBProgressHUDMode.Indeterminate
    loadingNotification.labelText = "Loading"
  }
  
  func showErrorHud() {
    print("showing error hud")
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
    print("enabling user interac again")
    self.navigationController?.view.userInteractionEnabled = true
    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
  }
}