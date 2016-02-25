import UIKit
import MDCSwipeToChoose

class RootController: UIViewController, MDCSwipeToChooseDelegate {
  
  var session: Session!
  
  var currentController: UIViewController!
  var subControllers = Dictionary<String, UIViewController>()
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    // Here you can init your properties
  }
  
  
}

// MARK: - Navigation


//extension RootController: SearchViewControllerDelegate {
//  func selectedSearchResult(searchResult: SimplePOI) {
//    dismissViewControllerAnimated(true, completion: nil)
//    
//    if searchResult.category == 180 { // street
//      if !(currentController is MapController) {
//        navigateToSubview("mapController", controllerType: MapController.self)
//      }
//    }
//    else if String(searchResult.category).hasPrefix("2") { // Attraction
//      if !(currentController is MapController) {
//        navigateToSubview("mapController", controllerType: MapController.self)
//      }
//    }
//    let subController = currentController as! SubController
//    subController.selectedSearchResult(searchResult)
//  }
//}
