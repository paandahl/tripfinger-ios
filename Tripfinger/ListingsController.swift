import Foundation

class ListingsController: UIViewController {
  
  let session: Session
  let searchDelegate: SearchViewControllerDelegate
  let displayMode: DisplayMode
  let container = UIView()
  let listController: ListController
  var swipeController: SwipeController?
  
  init(session: Session, searchDelegate: SearchViewControllerDelegate, categoryDescription: GuideText) {
    self.session = session
    self.searchDelegate = searchDelegate
    
    if session.currentSubCategory != nil {
      displayMode = DisplayMode.DIRECT_LIST
      listController = ListController(session: session, searchDelegate: searchDelegate, grouped: false, categoryDescription: categoryDescription)
    } else {
      switch session.currentCategory {
      case Listing.Category.ATTRACTIONS:
        displayMode = DisplayMode.WITH_SWIPER
        listController = ListController(session: session, searchDelegate: searchDelegate, grouped: false, categoryDescription: categoryDescription)
        swipeController = SwipeController(session: session, searchDelegate: searchDelegate)
      case Listing.Category.TRANSPORTATION:
        displayMode = DisplayMode.GROUPED_LIST
        listController = ListController(session: session, searchDelegate: searchDelegate, grouped: true, categoryDescription: categoryDescription)
      default:
        displayMode = DisplayMode.DIRECT_LIST
        listController = ListController(session: session, searchDelegate: searchDelegate, grouped: false, categoryDescription: categoryDescription)
      }
    }
    
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    let mapButton = UIBarButtonItem(image: UIImage(named: "maps_icon"), style: .Plain, target: self, action: "navigateToMap")
    mapButton.accessibilityLabel = "Map"
    let searchButton = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "navigateToSearch")
    navigationItem.rightBarButtonItems = [searchButton, mapButton]

    view.backgroundColor = UIColor.whiteColor()
    
    if let currentSubCategory = session.currentSubCategory {
      print("subcatty")
      navigationItem.title = currentSubCategory.entityName
    } else {
      print("no subcatty")
      navigationItem.title = session.currentCategory.entityName
    }
    
    view.addSubview(container)
    
    let items = ["Swipe", "List"]
    let segmentedControl = UISegmentedControl(items: items)
    segmentedControl.selectedSegmentIndex = 0
    segmentedControl.tintColor = UIColor.darkGrayColor()
    segmentedControl.backgroundColor = UIColor.whiteColor()
    segmentedControl.addTarget(self, action: "segmentedControllerChanged:", forControlEvents: .ValueChanged)
    
    let views = ["segmented": segmentedControl, "container": container]
    if displayMode == DisplayMode.WITH_SWIPER {
      view.addSubview(segmentedControl)
      view.addConstraints("V:|-10-[segmented(32)]-10-[container]-0-|", forViews: views)
      view.addConstraints("H:[segmented(200)]", forViews: views)
      view.addConstraint(.CenterX, forView: segmentedControl)
    }
    else {
      view.addConstraints("V:|-52-[container]-0-|", forViews: views)
    }
    view.addConstraints("H:|-0-[container]-0-|", forViews: views)

    if displayMode == DisplayMode.WITH_SWIPER {
      switchToSubview(swipeController!)
    }
    else {
      switchToSubview(listController)
    }
  }
  
  func segmentedControllerChanged(sender: UISegmentedControl) {
    if sender.selectedSegmentIndex == 0 {
      switchToSubview(swipeController!, from: listController)
    }
    else {
      switchToSubview(listController, from: swipeController)
    }
  }

  func switchToSubview(to: UIViewController, from: UIViewController? = nil) {
    if let from = from {
      from.view.removeFromSuperview()
      from.removeFromParentViewController()
    }
    addChildViewController(to)
    to.didMoveToParentViewController(self)
    to.view.frame = self.container.bounds
    container.addSubview(to.view)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    container.subviews[0].frame = container.bounds
  }
  
  func navigateToSearch() {
    let nav = UINavigationController()
    let regionId = session.currentRegion?.getId()
    let countryId = session.currentCountry?.getId()
    let searchController = SearchController(delegate: searchDelegate, regionId: regionId, countryId: countryId)
    nav.viewControllers = [searchController]
    presentViewController(nav, animated: true, completion: nil)
  }
  
  func navigateToMap() {
    let mapController = MapController(session: session)
    navigationController!.pushViewController(mapController, animated: true)
  }
  
  func updateUI() {
    listController.updateUI()
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    listController.parentViewWillDisappear(self)
  }
    
  enum DisplayMode {
    case WITH_SWIPER
    case GROUPED_LIST
    case DIRECT_LIST
  }
}