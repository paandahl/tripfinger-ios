import Foundation

class ListingsController: ListingsParentController {
  
  let categoryDescription: GuideText
  let displayMode: DisplayMode
  let container = UIView()
  let listController: ListController
  var swipeController: SwipeController?
  weak var mapNavigator: MapNavigator!

  init(regionId: String, countryMwmId: String, categoryDescription: GuideText, regionLicense: String?, mapNavigator: MapNavigator) {
    self.categoryDescription = categoryDescription
    self.mapNavigator = mapNavigator
    if categoryDescription.item.subCategory != 0 {
      displayMode = DisplayMode.DIRECT_LIST
      listController = ListController(regionId: regionId, countryMwmId: countryMwmId, grouped: false, categoryDescription: categoryDescription, regionLicense: regionLicense, mapNavigator: mapNavigator)
    } else {
      switch categoryDescription.getCategory() {
      case Listing.Category.ATTRACTIONS:
        displayMode = DisplayMode.WITH_SWIPER
        listController = ListController(regionId: regionId, countryMwmId: countryMwmId, grouped: false, categoryDescription: categoryDescription, regionLicense: regionLicense, mapNavigator: mapNavigator)
        swipeController = SwipeController(regionId: regionId, countryMwmId: countryMwmId)
      case Listing.Category.TRANSPORTATION:
        displayMode = DisplayMode.GROUPED_LIST
        listController = ListController(regionId: regionId, countryMwmId: countryMwmId, grouped: true, categoryDescription: categoryDescription, regionLicense: regionLicense, mapNavigator: mapNavigator)
      default:
        displayMode = DisplayMode.DIRECT_LIST
        listController = ListController(regionId: regionId, countryMwmId: countryMwmId, grouped: false, categoryDescription: categoryDescription, regionLicense: regionLicense, mapNavigator: mapNavigator)
      }
    }
    
    super.init(countryDownloadId: countryMwmId, offline: categoryDescription.item.offline)
    edgesForExtendedLayout = .None
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if categoryDescription.item.subCategory != 0 {
      print("subcatty")
      let subCategory = Listing.SubCategory(rawValue: categoryDescription.item.subCategory)!
      navigationItem.title = subCategory.entityName
    } else {
      navigationItem.title = categoryDescription.getCategory().entityName
    }
    
    view.addSubview(container)
    
    let items = ["Swipe", "List"]
    let segmentedControl = UISegmentedControl(items: items)
    segmentedControl.selectedSegmentIndex = 0
    segmentedControl.tintColor = UIColor.darkGrayColor()
    segmentedControl.backgroundColor = UIColor.whiteColor()
    segmentedControl.addTarget(self, action: #selector(ListingsController.segmentedControllerChanged(_:)), forControlEvents: .ValueChanged)
    
    let views = ["segmented": segmentedControl, "container": container]
    if displayMode == DisplayMode.WITH_SWIPER {
      view.addSubview(segmentedControl)
      view.addConstraints("V:|-10-[segmented(32)]-10-[container]-0-|", forViews: views)
      view.addConstraints("H:[segmented(200)]", forViews: views)
      view.addConstraint(.CenterX, forView: segmentedControl)
    } else {
      view.addConstraints("V:|-52-[container]-0-|", forViews: views)
    }
    view.addConstraints("H:|-0-[container]-0-|", forViews: views)

    if displayMode == DisplayMode.WITH_SWIPER {
      switchToSubview(swipeController!)
    } else {
      switchToSubview(listController)
    }
  }
  
  override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask.Portrait
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
    
  override func navigateToMap() {
    if !offline {
      showAlertWhenGuideIsNotDownloaded()
      return
    }
    mapNavigator.navigateToMap()
    MapsAppDelegateWrapper.openMapSearchWithQuery(categoryDescription.getCategory().entityName)
  }
  
  func updateUI() {
    listController.updateUI()
  }
  
  enum DisplayMode {
    case WITH_SWIPER
    case GROUPED_LIST
    case DIRECT_LIST
  }
}