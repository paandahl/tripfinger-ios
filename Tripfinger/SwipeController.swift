import UIKit
import MDCSwipeToChoose
import RealmSwift

class SwipeController: UIViewController, MDCSwipeToChooseDelegate {
  
  var noElementsLabel = UILabel()
  var attractionStack: [Attraction]?
  var session: Session!
//  var filterBox: FilterBox!
  
  let ChooseAttractionButtonHorizontalPadding: CGFloat = 80.0
  let ChooseAttractionButtonVerticalPadding: CGFloat = 20.0
  var frontCardView: AttractionCardView!
  var orignalFrontCardFrame: CGRect!
  var backCardView: AttractionCardView!
    
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
    loadAttractions()
  }
  
  override func viewDidLayoutSubviews() {
    if let frontCardView = frontCardView {
      orignalFrontCardFrame = frontCardView.frame
    }
  }
  
  func loadAttractions() {
    attractionStack = nil
    self.displayCards()
    session.loadAttractions {
      var newStack = [Attraction]()
      for attraction in self.session.currentAttractions {
        if attraction.listing.notes == nil || attraction.listing.notes!.likedState == GuideListingNotes.LikedState.NOT_YET_LIKED_OR_SWIPED {
          newStack.append(attraction)
        }
      }
      self.attractionStack = newStack
      SyncManager.run_async {
        dispatch_async(dispatch_get_main_queue()) {
          self.displayCards()
        }
      }
    }
  }
  
  func displayCards() {
    if let attractionStack = attractionStack {
      if attractionStack.count > 0 {
        noElementsLabel.hidden = true
        // Display the first ChoosePersonView in front. Users can swipe to indicate
        // whether they like or dislike the item displayed.
        setFrontCardViewFunc(popAttractionViewWithFrame(frontCardViewFrame())!)
        view.addSubview(frontCardView)
        addFrontCardConstraints()
        
        // Display the second ChoosePersonView in back. This view controller uses
        // the MDCSwipeToChooseDelegate protocol methods to update the front and
        // back views after each user swipe.
        if attractionStack.count > 1 {
          backCardView = popAttractionViewWithFrame(backCardViewFrame())!
          view.insertSubview(backCardView, belowSubview: frontCardView)
          addBackCardConstraints()
        }
      } else {
        noElementsLabel.hidden = false
        noElementsLabel.text = "No attractions to swipe."
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
//    if let currentRegion = session.currentRegion {
//      filterBox.regionNameLabel.text = "\(currentRegion.listing.item.name!):"
//    } else {
//      filterBox.regionNameLabel.text = "World:"
//    }
//    
//    filterBox.categoryLabel.text = session.currentCategory.entityName(session.currentRegion)
  }
  
  @IBAction func back() {
    self.tabBarController?.selectedIndex = 0
  }
  
  func addFrontCardConstraints() {
    let views: [String: UIView] = ["card": frontCardView]
    view.addConstraints("H:[card(300)]", forViews: views)
    view.addConstraints("V:|-20-[card]", forViews: views)
    view.addConstraint(NSLayoutAttribute.CenterX, forView: frontCardView)
  }
  
  func addBackCardConstraints() {
    let views: [String: UIView] = ["card": backCardView]
    view.addConstraints("H:[card(300)]", forViews: views)
    view.addConstraints("V:|-30-[card]", forViews: views)
    view.addConstraint(NSLayoutAttribute.CenterX, forView: backCardView)
  }
  
  func suportedInterfaceOrientations() -> UIInterfaceOrientationMask{
    return UIInterfaceOrientationMask.Portrait
  }
  
  
  // This is called when a user didn't fully swipe left or right.
  func viewDidCancelSwipe(view: UIView) -> Void{
    print("You couldn't decide on \(frontCardView.attraction.listing.item.name)");
  }
  
  // This is called then a user swipes the view fully left or right.
  func view(view: UIView, wasChosenWithDirection: MDCSwipeDirection) -> Void {
    // MDCSwipeToChooseView shows "NOPE" on swipes to the left,
    // and "LIKED" on swipes to the right.
    if(wasChosenWithDirection == MDCSwipeDirection.Left) {
      DatabaseService.saveLike(GuideListingNotes.LikedState.SWIPED_LEFT, attraction: frontCardView.attraction)
      print("You noped: \(frontCardView.attraction.listing.item.name)")
    }
    else{
      DatabaseService.saveLike(GuideListingNotes.LikedState.LIKED, attraction: frontCardView.attraction)
      print("You liked: \(frontCardView.attraction.listing.item.name)")
    }
    
    // MDCSwipeToChooseView removes the view from the view hierarchy
    // after it is swiped (this behavior can be customized via the
    // MDCSwipeOptions class). Since the front card view is gone, we
    // move the back card to the front, and create a new back card.
    if(backCardView != nil){
      setFrontCardViewFunc(backCardView)
      frontCardView.removeFromSuperview()
      self.view.addSubview(backCardView)
      addFrontCardConstraints()
    }
    
    backCardView = popAttractionViewWithFrame(backCardViewFrame())
    
    // Fade the back card into view.
    if(backCardView != nil){
      backCardView.alpha = 0.0
      self.view.insertSubview(backCardView, belowSubview: frontCardView)
      UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: {
        self.backCardView.alpha = 1.0
        },completion:nil)
      
      addBackCardConstraints()
    }
  }
  func setFrontCardViewFunc(frontCardView: AttractionCardView) -> Void{
    
    // Keep track of the person currently being chosen.
    // Quick and dirty, just for the purposes of this sample app.
    self.frontCardView = frontCardView
    self.frontCardView.accessibilityIdentifier = "frontCard"
  }
  
  
  func popAttractionViewWithFrame(frame:CGRect) -> AttractionCardView? {
    if(attractionStack!.count == 0){
      return nil;
    }
    
    // UIView+MDCSwipeToChoose and MDCSwipeToChooseView are heavily customizable.
    // Each take an "options" argument. Here, we specify the view controller as
    // a delegate, and provide a custom callback that moves the back card view
    // based on how far the user has panned the front card view.
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
    
    // Create a personView with the top person in the people array, then pop
    // that person off the stack.
    
    let personView: AttractionCardView = AttractionCardView(frame: frame, attraction: attractionStack!.removeLast(), delegate: self, options: options)
    return personView
    
  }
  
  func frontCardViewFrame() -> CGRect{
    let horizontalPadding:CGFloat = 20.0
    let topPadding:CGFloat = 60.0
    let bottomPadding:CGFloat = 130.0
    return CGRectMake(horizontalPadding,topPadding,CGRectGetWidth(self.view.frame) - (horizontalPadding * 2), CGRectGetHeight(self.view.frame) - bottomPadding)
  }
  
  func backCardViewFrame() ->CGRect{
    let frontFrame:CGRect = frontCardViewFrame()
    return CGRectMake(frontFrame.origin.x, frontFrame.origin.y + 10.0, CGRectGetWidth(frontFrame), CGRectGetHeight(frontFrame))
  }
  
  func constructNopeButton() -> Void{
    let button:UIButton =  UIButton(type: UIButtonType.System)
    let image:UIImage = UIImage(named:"nope")!
    button.frame = CGRectMake(ChooseAttractionButtonHorizontalPadding, CGRectGetMaxY(self.backCardView.frame) + ChooseAttractionButtonVerticalPadding, image.size.width, image.size.height)
    button.setImage(image, forState: UIControlState.Normal)
    button.tintColor = UIColor(red: 247.0/255.0, green: 91.0/255.0, blue: 37.0/255.0, alpha: 1.0)
    button.addTarget(self, action: "nopeFrontCardView", forControlEvents: UIControlEvents.TouchUpInside)
    self.view.addSubview(button)
  }
  
  func constructLikedButton() -> Void{
    let button:UIButton = UIButton(type: UIButtonType.System)
    let image:UIImage = UIImage(named:"liked")!
    button.frame = CGRectMake(CGRectGetMaxX(self.view.frame) - image.size.width - ChooseAttractionButtonHorizontalPadding, CGRectGetMaxY(self.backCardView.frame) + ChooseAttractionButtonVerticalPadding, image.size.width, image.size.height)
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

extension SwipeController: AttractionCardContainer {
  
  func showDetail(attraction: Attraction) {
    let vc = DetailController()
    vc.attraction = attraction
    self.navigationController!.pushViewController(vc, animated: true)
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