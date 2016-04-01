import UIKit

class GuideViewController: UIViewController {
 
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.greenColor()
    print("view.translatesAutoresizingMaskIntoConstraints: \(view.translatesAutoresizingMaskIntoConstraints)")
    let button = UIButton(type: .System)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Go to Map", forState: .Normal)
    button.sizeToFit()
    button.backgroundColor = UIColor.yellowColor()
    button.addTarget(self, action: "navigateToMap", forControlEvents: .TouchUpInside)
    view.addSubview(button)
    view.addConstraint(NSLayoutConstraint(item: button, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0))
    view.addConstraint(NSLayoutConstraint(item: button, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1.0, constant: 0))
  }
  
  
  func navigateToMap() {
    print("navigating to map")
    
    let vc = MapsAppDelegateWrapper.getMapViewController()

    navigationController!.pushViewController(vc, animated: true)
//    self.presentViewController(vc, animated: true, completion: nil)
  }
}