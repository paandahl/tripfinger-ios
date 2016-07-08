import Foundation

class SuperScrollView: UIScrollView {
  override func touchesShouldCancelInContentView(view: UIView) -> Bool {
    return true
  }
}

class DetailController: ListingsParentController {
  
  let entity: TripfingerEntity

  let scrollView = SuperScrollView()
  let placePageViews: [UIView]
  
  init(entity: TripfingerEntity, countryDownloadId: String, placePageViews: [UIView]) {
    self.entity = entity
    scrollView.canCancelContentTouches = true
    self.placePageViews = placePageViews
    super.init(countryDownloadId: countryDownloadId, offline: entity.offline)
    addObserver(DatabaseService.TFCountrySavedNotification, selector: #selector(countryDownloaded(_:)))
    addObserver(DatabaseService.TFLikedStatusChangedNotification, selector: #selector(likedStatusChanged))
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = entity.name

    let infoView = placePageViews[0]
    let actionBar = placePageViews[1]
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
    calculateScrollViewSize()
  }
  
  func likedStatusChanged() {
    if let listingNotes = DatabaseService.getListingNotes(entity.tripfingerId) {
      entity.liked = listingNotes.likedState == GuideListingNotes.LikedState.LIKED
      calculateScrollViewSize()
    }
  }
  
  func calculateScrollViewSize() {
    let uiTableView = placePageViews[0].subviews[2].subviews[1] as! UITableView
    let height: CGFloat = uiTableView.contentSize.height + placePageViews[1].frame.size.height + 100;
    scrollView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width, height)
  }
  
  override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask.Portrait
  }

  override func navigateToMap() {
    if !offline {
      showAlertWhenGuideIsNotDownloaded()
      return 
    }
    let vc = MapsAppDelegateWrapper.getMapViewController()
    navigationController!.pushViewController(vc, animated: true)
    MapsAppDelegateWrapper.selectListing(entity)
  }  
}
