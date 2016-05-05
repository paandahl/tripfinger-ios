import Foundation

class SuperScrollView: UIScrollView {
  override func touchesShouldCancelInContentView(view: UIView) -> Bool {
    return true
  }
}

class DetailController: UIViewController {
  
  let session: Session
  let searchDelegate: SearchViewControllerDelegate

  let scrollView = SuperScrollView()
  let placePageViews: [UIView]
  
  init(session: Session, searchDelegate: SearchViewControllerDelegate, placePageViews: [UIView]) {
    self.session = session
    self.searchDelegate = searchDelegate
    scrollView.canCancelContentTouches = true
    self.placePageViews = placePageViews
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    navigationItem.title = session.currentListing.listing.item.name
    let mapButton = UIBarButtonItem(image: UIImage(named: "maps_icon"), style: .Plain, target: self, action: "navigateToMap")
    mapButton.accessibilityLabel = "Map"
    let searchButton = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "navigateToSearch")
    navigationItem.rightBarButtonItems = [searchButton, mapButton]

    let infoView = placePageViews[0]
    let actionBar = placePageViews[1]
    view.backgroundColor = UIColor.whiteColor()
    view.addSubview(scrollView)
    let res = UIScreen.mainScreen().bounds.size
    scrollView.frame = CGRectMake(0, 0, res.width, res.height - actionBar.height)
    scrollView.addSubview(infoView)
    actionBar.frame = CGRectMake(0, res.height - actionBar.height, res.width, actionBar.height)
    view.addSubview(actionBar)
    for placePageView in placePageViews {
      placePageView.userInteractionEnabled = true
    }
  }
  
  override func viewDidLayoutSubviews() {
    let uiTableView = placePageViews[0].subviews[2].subviews[1] as! UITableView
    let height: CGFloat = uiTableView.contentSize.height + placePageViews[1].frame.size.height + 100;
    scrollView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width, height)
  }
  
  override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask.Portrait
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
    let vc = MapsAppDelegateWrapper.getMapViewController()
    navigationController!.pushViewController(vc, animated: true)
    let listing = session.currentListing.listing
    let margin = 0.01
    let botLeft = CLLocationCoordinate2DMake(listing.latitude - margin, listing.longitude - margin)
    let topRight = CLLocationCoordinate2DMake(listing.latitude + margin, listing.longitude + margin)
    MapsAppDelegateWrapper.navigateToRect(botLeft, topRight: topRight)
  }
}