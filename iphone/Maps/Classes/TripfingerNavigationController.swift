import Foundation

class TripfingerNavigationController: UINavigationController {
  override func supportedInterfaceOrientations() -> UInt {
    let className = String(topViewController!.dynamicType)
    if className == "MapViewController" {
      return UInt(UIInterfaceOrientationMask.All.rawValue)
    } else {
      return UInt(UIInterfaceOrientationMask.Portrait.rawValue)
    }
  }
  
  func alert(message: String) {
    let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .Alert)
    let defaultAction = UIAlertAction(title: "OK", style: .Default) { alertAction in
      self.dismissViewControllerAnimated(true, completion: nil)
    }
    alertController.addAction(defaultAction)
    self.presentViewController(alertController, animated: true, completion: nil)
  }
}
