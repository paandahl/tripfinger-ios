import Foundation
import MBProgressHUD

extension UIView {
  func addObserver(name: String, selector: Selector) {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: name, object: nil)
  }
  
  func delay(delay: Double, selector: Selector) {
    NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(delay), target: self, selector: selector, userInfo: nil, repeats: false)
  }
  
  func showLoadingHud(disableUserInteraction disableUserInteraction: Bool = true) {
    let loadingNotification = MBProgressHUD.showHUDAddedTo(self, animated: true)
    loadingNotification.mode = MBProgressHUDMode.Indeterminate
    loadingNotification.labelText = "Loading"
  }
  
  func showErrorHud() {
    hideHuds()
    let loadingNotification = MBProgressHUD.showHUDAddedTo(self, animated: true)
    loadingNotification.mode = MBProgressHUDMode.CustomView
    loadingNotification.labelText = "Connection failed"
    
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue()) {
      self.hideHuds()
    }
  }
  
  func hideHuds() {
    MBProgressHUD.hideAllHUDsForView(self, animated: true)
  }

}

extension UIViewController {

  func addObserver(name: String, selector: Selector) {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: name, object: nil)
  }
  
  func delay(delay: Double, selector: Selector) {
    NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(delay), target: self, selector: selector, userInfo: nil, repeats: false)
  }

  func showLoadingHud(disableUserInteraction disableUserInteraction: Bool = true) {
    print("disabling user interac")
    self.navigationController!.view.userInteractionEnabled = !disableUserInteraction
    self.view.showLoadingHud()
  }
  
  func showErrorHud() {
    print("showing error hud")
    self.view.showErrorHud()
  }
  
  func hideHuds() {
    print("enabling user interac again")
    self.navigationController?.view.userInteractionEnabled = true
    self.view.hideHuds()
  }
}