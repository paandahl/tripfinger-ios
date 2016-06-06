import Foundation

class SuperScrollView: UIScrollView {
  override func touchesShouldCancelInContentView(view: UIView) -> Bool {
    return true
  }
}

class DetailController: UIViewController {
  
  let session: Session

  let scrollView = SuperScrollView()
  let placePageViews: [UIView]
  
  init(session: Session, placePageViews: [UIView]) {
    self.session = session
    scrollView.canCancelContentTouches = true
    self.placePageViews = placePageViews
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    var barButtons = [UIBarButtonItem]()
    let searchButton = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: #selector(navigateToSearch))
    barButtons.append(searchButton)
    navigationItem.title = session.currentListing.listing.item.name
    let mapButton = UIBarButtonItem(image: UIImage(named: "maps_icon"), style: .Plain, target: self, action: #selector(navigateToMap))
    mapButton.accessibilityLabel = "Map"
    if session.currentListing.item().offline {
      barButtons.append(mapButton)
    }
    navigationItem.rightBarButtonItems = barButtons

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
    let vc = MapsAppDelegateWrapper.getMapViewController()
    navigationController!.pushViewController(vc, animated: true)
    MapsAppDelegateWrapper.openSearch()
  }
  
  func navigateToMap() {
    let vc = MapsAppDelegateWrapper.getMapViewController()
    navigationController!.pushViewController(vc, animated: true)
    let entity = TripfingerEntity(listing: session.currentListing)
    MapsAppDelegateWrapper.selectListing(entity)
  }
}