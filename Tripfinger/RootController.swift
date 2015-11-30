import UIKit
import MDCSwipeToChoose

class RootController: UIViewController, MDCSwipeToChooseDelegate {
  
  @IBOutlet weak var toolbar: UIToolbar!
  @IBOutlet weak var container: UIView!
  @IBOutlet weak var segmentedControllerGuide: UISegmentedControl!
  @IBOutlet weak var secondSegmentedController: UISegmentedControl!
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
  
  override func viewDidLoad(){
    super.viewDidLoad()
    
    segmentedControllerGuide.removeAllSegments()
    segmentedControllerGuide.insertSegmentWithTitle("Guide", atIndex: 0, animated: false)
    if let rightButton = self.navigationItem.rightBarButtonItem {
      if let itemView = rightButton.valueForKey("view") as? UIView {
        var frameRect = itemView.frame;
        frameRect.size.width = 55;
        itemView.frame = frameRect        
      }
    }
    
    navigateToSubview("guideController", controllerType: GuideController.self)
    
    segmentedControllerGuide.selectedSegmentIndex = 0
    secondSegmentedController.selectedSegmentIndex = UISegmentedControlNoSegment
    
  }
  
  @IBAction func firstSegmentChanged(sender: UISegmentedControl) {
    secondSegmentedController.selectedSegmentIndex = UISegmentedControlNoSegment
    navigateToSubview("guideController", controllerType: GuideController.self)
  }
  
  @IBAction func secondSegmentChanged(sender: UISegmentedControl) {
    segmentedControllerGuide.selectedSegmentIndex = UISegmentedControlNoSegment
    switch (sender.selectedSegmentIndex) {
    case 0:
      navigateToSubview("swipeController", controllerType: SwipeController.self)
    case 1:
      navigateToSubview("listController", controllerType: ListController.self)
    case 2:
      navigateToSubview("mapController", controllerType: MapDisplayViewController.self)
    default:
      break
    }
  }
  
  func navigateToSubview<T: UIViewController>(name: String, controllerType: T.Type) {
    var controller = subControllers[name]
    if controller == nil {
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      controller = storyboard.instantiateViewControllerWithIdentifier(name) as? T
      var subController = controller as! SubController
      subController.session = session
      subControllers[name] = controller
      if controllerType == GuideController.self {
        let guideController = controller as! GuideController
        guideController.delegate = self
      }
    }
    else {
      controller?.viewWillAppear(true)
    }
    switchSubview(controller!)
  }
  
  func switchSubview(newView: UIViewController) {
    
    addChildViewController(newView)
    newView.didMoveToParentViewController(self)
    newView.view.frame = self.container.bounds
    
    container.addSubview(newView.view)
    if let currentController = currentController {
      currentController.removeFromParentViewController()
    }
    currentController = newView
  }
}

// MARK: - Navigation

extension RootController {
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowSearch" {
      let navigationController = segue.destinationViewController as! UINavigationController
      let searchViewController = navigationController.viewControllers[0] as! SearchViewController
      searchViewController.delegate = self
    }
  }
}

extension RootController: SearchViewControllerDelegate {
  func selectedSearchResult(searchResult: SearchResult) {
    
    if searchResult.resultType == .Street {
      if !(currentController is MapDisplayViewController) {
        segmentedControllerGuide.selectedSegmentIndex = UISegmentedControlNoSegment
        secondSegmentedController.selectedSegmentIndex = 2
        navigateToSubview("mapController", controllerType: MapDisplayViewController.self)
      }
      let mapController = currentController as! MapDisplayViewController
      mapController.selectedSearchResult(searchResult)
    }
  }
}

extension RootController: GuideControllerDelegate {
  
  func categorySelected(category: Attraction.Category) {
    
    print("SWITCHING CAT")
    session.currentCategory = category
    segmentedControllerGuide.selectedSegmentIndex = UISegmentedControlNoSegment
    secondSegmentedController.selectedSegmentIndex = 0
    navigateToSubview("swipeController", controllerType: SwipeController.self)
  }
  
  func navigateInternally() {
    
    navigateToSubview("guideController", controllerType: GuideController.self)
//    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//    let vc = storyboard.instantiateViewControllerWithIdentifier("rootController") as? RootController
//    vc!.session = session
    
//    vc.currentRegion = currentRegion
//    vc.currentSection = currentCategoryDescriptions[indexPath.row + 2]
//    vc.guideItemExpanded = true
//    vc.delegate = delegate
//    navigationController?.pushViewController(vc!, animated: true)
//
//    
//    navigationItem.leftBarButtonItem
  }
}