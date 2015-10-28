import UIKit
import MDCSwipeToChoose

class SwipeController: UIViewController, SubController, MDCSwipeToChooseDelegate {
    
    var session: Session!
    @IBOutlet weak var filterBox: UIView!
    @IBOutlet weak var filterControls: UIView!
    @IBOutlet weak var regionNameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var noElementsLabel: UILabel!
    
    var attractions:[Attraction] = []
    var category: Attraction.Category!
    let ChooseAttractionButtonHorizontalPadding: CGFloat = 80.0
    let ChooseAttractionButtonVerticalPadding: CGFloat = 20.0
    var currentAttraction: Attraction!
    var frontCardView: ChooseAttractionView!
    var frontCardVerticalConstraints = [NSLayoutConstraint]()
    var orignalFrontCardFrame: CGRect!
    var backCardView: ChooseAttractionView!
    var backCardVerticalConstraints = [NSLayoutConstraint]()
    
    var currentController: UIViewController!
    var guideController: GuideController?
    var mapController: MapDisplayViewController?
    
    override func viewDidLoad(){
        super.viewDidLoad()
                
        filterControls.layer.borderColor = UIColor.darkGrayColor().CGColor
        filterControls.layer.borderWidth = 0.5;
        
        let singleTap = UITapGestureRecognizer(target: self, action: "filterClick")
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        filterControls.addGestureRecognizer(singleTap)
        filterControls.userInteractionEnabled = true

        
        if let currentCategory = session.currentCategory {
            category = currentCategory
        }
        else {
            category = Attraction.Category.EXPLORE_CITY
            session.currentCategory = category
        }
        
        session.loadBrusselsAsCurrentRegionIfEmpty() {
            self.loadAttractions()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if let currentCategory = session.currentCategory {
            if category != currentCategory {
                category = currentCategory
                reloadCards()
            }
        }
    }
    
    func reloadCards() {
        if (frontCardView != nil) {
            cleanCards()
        }
        loadAttractions()
    }
    
    func cleanCards() {
        frontCardView.removeFromSuperview()
        backCardView.removeFromSuperview()
        view.removeConstraints(frontCardVerticalConstraints)
        view.removeConstraints(backCardVerticalConstraints)
        frontCardVerticalConstraints = [NSLayoutConstraint]()
        backCardVerticalConstraints = [NSLayoutConstraint]()
    }
    
    func filterClick() {
        performSegueWithIdentifier("showFilter", sender: nil)
    }
    
    func loadAttractions() {
        self.regionNameLabel.text = "\(self.session.currentRegion!.name!):"
        self.categoryLabel.text = self.category.entityName

        session.loadAttractions() {
            self.attractions = self.session.currentAttractions
            print("loaded \(self.attractions.count) attractions")
            self.displayCards()
        }
    }
    
    func displayCards() {
        
        if attractions.count > 0 {
            noElementsLabel.hidden = true
            // Display the first ChoosePersonView in front. Users can swipe to indicate
            // whether they like or dislike the item displayed.
            setFrontCardViewFunc(popAttractionViewWithFrame(frontCardViewFrame())!)
            view.insertSubview(frontCardView, belowSubview: filterBox)
            addFrontCardConstraints()
            
            // Display the second ChoosePersonView in back. This view controller uses
            // the MDCSwipeToChooseDelegate protocol methods to update the front and
            // back views after each user swipe.
            backCardView = popAttractionViewWithFrame(backCardViewFrame())!
            view.insertSubview(backCardView, belowSubview: frontCardView)
            addBackCardConstraints()
        }
        else {
            noElementsLabel.hidden = false
        }
    }
    
    @IBAction func back() {
        self.tabBarController?.selectedIndex = 0
    }
    
    func addFrontCardConstraints() {
        let views = ["card": frontCardView, "filter": filterBox!]
        view.addConstraints("H:[card(301)]", forViews: views)
        frontCardVerticalConstraints = view.addConstraints("V:[filter]-10-[card]", forViews: views)
        view.addConstraint(NSLayoutAttribute.CenterX, forView: frontCardView)
    }
    
    func addBackCardConstraints() {
        let views = ["card": backCardView, "filter": filterBox!]
        view.addConstraints("H:[card(302)]", forViews: views)
        backCardVerticalConstraints = view.addConstraints("V:[filter]-20-[card]", forViews: views) 
        view.addConstraint(NSLayoutAttribute.CenterX, forView: backCardView)
    }
    
    override func viewDidLayoutSubviews() {
        if let frontCardView = frontCardView {
            orignalFrontCardFrame = frontCardView.frame
        }
    }
    
    func suportedInterfaceOrientations() -> UIInterfaceOrientationMask{
        return UIInterfaceOrientationMask.Portrait
    }
    
    
    // This is called when a user didn't fully swipe left or right.
    func viewDidCancelSwipe(view: UIView) -> Void{
        
        print("You couldn't decide on \(currentAttraction.name)");
    }
    
    // This is called then a user swipes the view fully left or right.
    func view(view: UIView, wasChosenWithDirection: MDCSwipeDirection) -> Void{
        
        // MDCSwipeToChooseView shows "NOPE" on swipes to the left,
        // and "LIKED" on swipes to the right.
        if(wasChosenWithDirection == MDCSwipeDirection.Left){
            print("You noped: \(currentAttraction.name)")
        }
        else{
            
            print("You liked: \(currentAttraction.name)")
        }
        
        // MDCSwipeToChooseView removes the view from the view hierarchy
        // after it is swiped (this behavior can be customized via the
        // MDCSwipeOptions class). Since the front card view is gone, we
        // move the back card to the front, and create a new back card.
        if(backCardView != nil){
            setFrontCardViewFunc(backCardView)
        }
        
        backCardView = popAttractionViewWithFrame(backCardViewFrame())
        //if(true){
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
    func setFrontCardViewFunc(frontCardView: ChooseAttractionView) -> Void{
        
        // Keep track of the person currently being chosen.
        // Quick and dirty, just for the purposes of this sample app.
        self.frontCardView = frontCardView
        currentAttraction = frontCardView.attraction
        
        if (backCardVerticalConstraints.count != 0) {
            view.removeConstraints(backCardVerticalConstraints)
            addFrontCardConstraints()
        }
    }
    
    
    func popAttractionViewWithFrame(frame:CGRect) -> ChooseAttractionView? {
        if(self.attractions.count == 0){
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
        
        let personView: ChooseAttractionView = ChooseAttractionView(frame: frame, attraction: self.attractions[0], delegate: self, options: options)
        self.attractions.removeAtIndex(0)
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
        if segue.identifier == "showDetail" {
            let detailController = segue.destinationViewController as! DetailController
            detailController.attraction = sender as! Attraction
        }
        else if segue.identifier == "showFilter" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let filterController = navigationController.viewControllers[0] as! FilterController
            filterController.session = session
            filterController.delegate = self
        }
    }
}

extension SwipeController: AttractionCardContainer {

    func showDetail(attraction: Attraction) {
        performSegueWithIdentifier("showDetail", sender: attraction)
    }
}

extension SwipeController: FilterControllerDelegate {

    func filterChanged() {
        dismissViewControllerAnimated(true, completion: nil)
        print("filterChanged")
        viewWillAppear(true)        
    }
}