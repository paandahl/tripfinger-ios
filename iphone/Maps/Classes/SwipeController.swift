import UIKit
import MDCSwipeToChoose
import RealmSwift

class SwipeController: UIViewController, MDCSwipeToChooseDelegate {
  
  var noElementsLabel = UILabel()
  var listingStack: [Listing]?
  let session: Session
  var cardWidth: CGFloat!
  var cardHeight: CGFloat!
//  var filterBox: FilterBox!
  
  let ChooseListingButtonHorizontalPadding: CGFloat = 80.0
  let ChooseListingButtonVerticalPadding: CGFloat = 20.0
  var frontCardView: ListingCardView!
  var orignalFrontCardFrame: CGRect!
  var backCardView: ListingCardView!
  
  init(session: Session) {
    self.session = session
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad(){
//    filterBox = UINib(nibName: "FilterBox", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! FilterBox
//    filterBox.delegate = self
//    view.addSubview(filterBox)
//    view.addConstraints("V:|-10-[filters(44)]", forViews: ["filters": filterBox])
    view.addSubview(noElementsLabel)
    view.addConstraint(.CenterX, forView: noElementsLabel)
    view.addConstraint(.CenterY, forView: noElementsLabel)
  }
  
  override func viewWillAppear(animated: Bool) {
    loadListings()
  }
  
  override func viewDidLayoutSubviews() {
    if let frontCardView = frontCardView, let backCardView = backCardView {
      let frame = frontCardView.frame
      backCardView.frame = CGRectMake(frame.origin.x + 10, frame.origin.y + 10, frame.width, frame.height)
      orignalFrontCardFrame = frontCardView.frame
    }
  }
  
  /*
   * Load attractions that have not yet been swiped onto the stack.
   */
  func loadListings() {
    listingStack = nil
    self.displayCards()
    let failure = {
      self.listingStack = [Listing]()
      self.noElementsLabel.text = "Connection failed."
      self.displayCards()
    }
    session.loadListings(failure) {
      var newStack = [Listing]()
      for listing in self.session.currentListings {
        if listing.listing.notes == nil || listing.listing.notes!.likedState == GuideListingNotes.LikedState.NOT_YET_LIKED_OR_SWIPED {
          newStack.append(listing)
        }
      }
      self.listingStack = newStack
      SyncManager.run_async {
        dispatch_async(dispatch_get_main_queue()) {
          if !NetworkUtil.connectedToNetwork() && !self.session.currentRegion.item().offline {
            self.noElementsLabel.text = "You are currently offline."
          } else {
            self.noElementsLabel.text = "No attractions to swipe."
          }
          self.displayCards()
        }
      }
    }
  }
  
  func displayCards() {
    if let attractionStack = listingStack {
      if attractionStack.count > 0 {
        noElementsLabel.hidden = true

        cardWidth = view.bounds.width - 40
        cardHeight = cardWidth * 1.33
        if cardHeight > (view.bounds.height - 30) {
          cardHeight = view.bounds.height - 30
          cardWidth = cardHeight * 0.75
        }
        setFrontCardViewFunc(popListingViewWithFrame(CGRectMake(0, 0, cardWidth, cardHeight))!)
        view.addSubview(frontCardView)
        addFrontCardConstraints(cardWidth, height: cardHeight)
        
        if attractionStack.count > 1 {
          backCardView = popListingViewWithFrame(CGRectMake(0, 0, cardWidth, cardHeight))!
          view.insertSubview(backCardView, belowSubview: frontCardView)
        }
      } else {
        noElementsLabel.hidden = false
        noElementsLabel.sizeToFit()
      }
    } else {
      
      if (frontCardView != nil) {
        frontCardView.removeFromSuperview()
      }
      if (backCardView != nil) {
        backCardView.removeFromSuperview()
        backCardView = nil
      }

      noElementsLabel.hidden = false
      noElementsLabel.text = "Loading..."
      noElementsLabel.sizeToFit()
    }
  }
  
  @IBAction func back() {
    self.tabBarController?.selectedIndex = 0
  }
  
  func addFrontCardConstraints(width: CGFloat, height: CGFloat) {
    print("bounds: \(view.bounds)")
    print("frame: \(frontCardView.frame)")
    let views: [String: UIView] = ["card": frontCardView]
    view.addConstraint(.CenterX, forView: frontCardView)
    view.addConstraint(.CenterY, forView: frontCardView)
//    frontCardView.backgroundColor = UIColor.greenColor()
//    view.addConstraint(NSLayoutConstraint(item: frontCardView, attribute: .Width, relatedBy: .Equal, toItem: frontCardView, attribute: .Height, multiplier: 0.75, constant: 0))
//    view.addConstraints("V:|-(>=20)-[card]-(>=20)-|", forViews: views)
//    view.addConstraints("H:|-(>=20)-[card]-(>=20)-|", forViews: views)
    view.addConstraints("V:[card(\(height))]", forViews: views)
    view.addConstraints("H:[card(\(width))]", forViews: views)
    
    
//    view.addConstraint(NSLayoutAttribute.CenterX, forView: frontCardView)
  }
  
  func suportedInterfaceOrientations() -> UIInterfaceOrientationMask{
    return UIInterfaceOrientationMask.Portrait
  }

  
  // This is called when a user didn't fully swipe left or right.
  func viewDidCancelSwipe(view: UIView) -> Void{
    print("You couldn't decide on \(frontCardView.listing.listing.item.name)");
  }
  
  // This is called then a user swipes the view fully left or right.
  func view(view: UIView, wasChosenWithDirection: MDCSwipeDirection) -> Void {
    // MDCSwipeToChooseView shows "NOPE" on swipes to the left,
    // and "LIKED" on swipes to the right.
    if(wasChosenWithDirection == MDCSwipeDirection.Left) {
      DatabaseService.saveLike(GuideListingNotes.LikedState.SWIPED_LEFT, listing: frontCardView.listing)
      print("You noped: \(frontCardView.listing.listing.item.name)")
    }
    else{
      DatabaseService.saveLike(GuideListingNotes.LikedState.LIKED, listing: frontCardView.listing)
      print("You liked: \(frontCardView.listing.listing.item.name)")
    }
    
    if(backCardView != nil){
      setFrontCardViewFunc(backCardView)
      frontCardView.removeFromSuperview()
      self.view.addSubview(backCardView)
      addFrontCardConstraints(cardWidth, height: cardHeight)
    }
    
    backCardView = popListingViewWithFrame(CGRectMake(0, 0, cardWidth, cardHeight))
    
    // Fade the back card into view.
    if(backCardView != nil){
      backCardView.alpha = 0.0
      self.view.insertSubview(backCardView, belowSubview: frontCardView)
      UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: {
        self.backCardView.alpha = 1.0
        },completion:nil)
    }
  }
  func setFrontCardViewFunc(frontCardView: ListingCardView) -> Void{
    
    self.frontCardView = frontCardView
    self.frontCardView.accessibilityIdentifier = "frontCard"
  }
  
  
  func popListingViewWithFrame(frame:CGRect) -> ListingCardView? {
    if(listingStack!.count == 0){
      return nil;
    }
    
    let options:MDCSwipeToChooseViewOptions = MDCSwipeToChooseViewOptions()
    options.delegate = self
    //options.threshold = 160.0
    options.onPan = { state -> Void in
      if(self.backCardView != nil) {
        //                var frame:CGRect = self.frontCardViewFrame()
        let frame = self.orignalFrontCardFrame
        self.backCardView.frame = CGRectMake(frame.origin.x, frame.origin.y+10-(state.thresholdRatio * 10.0), CGRectGetWidth(frame), CGRectGetHeight(frame))
      }
    }
    options.likedText = "Liked"
    
    return ListingCardView(frame: frame, listing: listingStack!.removeLast(), delegate: self, options: options)
  }
  
  func constructNopeButton() -> Void{
    let button:UIButton =  UIButton(type: UIButtonType.System)
    let image:UIImage = UIImage(named:"nope")!
    button.frame = CGRectMake(ChooseListingButtonHorizontalPadding, CGRectGetMaxY(self.backCardView.frame) + ChooseListingButtonVerticalPadding, image.size.width, image.size.height)
    button.setImage(image, forState: UIControlState.Normal)
    button.tintColor = UIColor(red: 247.0/255.0, green: 91.0/255.0, blue: 37.0/255.0, alpha: 1.0)
    button.addTarget(self, action: "nopeFrontCardView", forControlEvents: UIControlEvents.TouchUpInside)
    self.view.addSubview(button)
  }
  
  func constructLikedButton() -> Void{
    let button:UIButton = UIButton(type: UIButtonType.System)
    let image:UIImage = UIImage(named:"liked")!
    button.frame = CGRectMake(CGRectGetMaxX(self.view.frame) - image.size.width - ChooseListingButtonHorizontalPadding, CGRectGetMaxY(self.backCardView.frame) + ChooseListingButtonVerticalPadding, image.size.width, image.size.height)
    button.setImage(image, forState:UIControlState.Normal)
    button.tintColor = UIColor(red: 29.0/255.0, green: 245.0/255.0, blue: 106.0/255.0, alpha: 1.0)
    button.addTarget(self, action: "likeFrontCardView", forControlEvents: UIControlEvents.TouchUpInside)
    self.view.addSubview(button)
    
  }
  func nopeFrontCardView() -> Void{
    self.frontCardView.mdc_swipe(MDCSwipeDirection.Left)
  }
  func likeFrontCardView() -> Void{
    self.frontCardView.mdc_swipe(MDCSwipeDirection.Right)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showFilter" {
      let navigationController = segue.destinationViewController as! UINavigationController
      let filterController = navigationController.viewControllers[0] as! FilterController
      filterController.session = session
      filterController.delegate = self
    }
  }
  
  func selectedSearchResult(searchResult: SimplePOI, stopSpinner: () -> ()) {
  }
}

extension SwipeController: ListingCardContainer {
  
  func showDetail(listing: Listing) {
    self.session.currentListing = listing
    let entity = TripfingerEntity(listing: listing)
    MapsAppDelegateWrapper.openPlacePage(entity)
  }
}

extension SwipeController: FilterBoxDelegate {
  
  func filterClick() {
    performSegueWithIdentifier("showFilter", sender: nil)
  }
}

extension SwipeController: FilterControllerDelegate {
  
  func filterChanged() {
    dismissViewControllerAnimated(true, completion: nil)
    viewWillAppear(true)
  }
}