import UIKit
import MDCSwipeToChoose

class RootController: UIViewController, MDCSwipeToChooseDelegate {
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var segmentedControllerGuide: UISegmentedControl!
    @IBOutlet weak var secondSegmentedController: UISegmentedControl!
    var session: Session!
    
    var currentController: UIViewController!
    var guideController: GuideController?
    var mapController: MapDisplayViewController?
    var swipeController: SwipeController?
    var listController: ListController?
    
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
        let itemView = self.navigationItem.rightBarButtonItem?.valueForKey("view") as! UIView
        var frameRect = itemView.frame;
        frameRect.size.width = 55;
        itemView.frame = frameRect
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guideController = storyboard.instantiateViewControllerWithIdentifier("guideController") as? GuideController
        guideController?.session = session
        switchSubview(guideController!)
        
        segmentedControllerGuide.selectedSegmentIndex = 0
        secondSegmentedController.selectedSegmentIndex = UISegmentedControlNoSegment

    }

    @IBAction func firstSegmentChanged(sender: UISegmentedControl) {
        secondSegmentedController.selectedSegmentIndex = UISegmentedControlNoSegment
        switchSubview(guideController!)
    }
    
    @IBAction func secondSegmentChanged(sender: UISegmentedControl) {
        segmentedControllerGuide.selectedSegmentIndex = UISegmentedControlNoSegment
        switch (sender.selectedSegmentIndex) {
        case 0:
            if swipeController == nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                swipeController = storyboard.instantiateViewControllerWithIdentifier("swipeController") as? SwipeController
                swipeController?.session = session
            }
            switchSubview(swipeController!)
        case 1:
            if listController == nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                listController = storyboard.instantiateViewControllerWithIdentifier("listController") as? ListController
                listController?.session = session
            }
            switchSubview(listController!)
        case 2:
            if mapController == nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                mapController = storyboard.instantiateViewControllerWithIdentifier("mapController") as? MapDisplayViewController
                mapController?.session = session
            }
            switchSubview(mapController!)
        default:
            break
        }
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