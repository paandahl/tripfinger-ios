import SKMaps
import RealmSwift
import BrightFutures
import Alamofire

class MapController: UIViewController, SKMapViewDelegate, CLLocationManagerDelegate, SKPositionerServiceDelegate {
  
  let annotationService: AnnotationService
  let session: Session
  var positionInitiatedFromRegion: Region?
  
  var calloutView: AnnotationCalloutView!
  var positionButtonMargin: NSLayoutConstraint!
  var pois = List<SimplePOI>()
  var mapView: SKMapView!
  var locationManager: CLLocationManager!
  var positionView: UIImageView!
  var positionView2: UIImageView!
  var previousHeading: CGFloat = 0.0
  var mapPoisRequest: Request!
  
  init(session: Session) {
    self.session = session
    self.annotationService = AnnotationService()
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {    
    super.viewDidLoad()
    
    let searchButton = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "navigateToSearch")
    navigationItem.rightBarButtonItems = [searchButton]
    navigationItem.title = session.currentCategory.entityName

    mapView = SKMapView(frame: CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)))
    mapView.accessibilityIdentifier = "mapView"
    mapView.accessibilityValue = String(0) // acts as a counter for liked items, used in UI tests
    let languageSettings = SKMapInternationalizationSettings.mapInternationalization()
    languageSettings.backupToTransliterated = true
    languageSettings.primaryInternationalLanguage = SKLanguage.MapLanguageEN
    languageSettings.fallbackInternationalLanguage = SKLanguage.MapLanguageFR
    languageSettings.primaryOption = SKMapInternationalizationOption.International
    languageSettings.fallbackOption = SKMapInternationalizationOption.Transliterated
    languageSettings.showBothOptions = false
    mapView.settings.mapInternationalization = languageSettings

    mapView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
    mapView.delegate = self
    mapView.settings.rotationEnabled = false
    mapView.settings.inertiaEnabled = false
    mapView.settings.orientationIndicatorType = SKOrientationIndicatorType.None
    mapView.settings.headingMode = SKHeadingMode.RotatingHeading
    
    view.addSubview(mapView)
    
    let positionButton = UIButton(type: .System)
    let positionButtonImage = UIImage(named: "ic_geoposition")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
    positionButton.setImage(positionButtonImage, forState: .Normal)
//    positionButton.setTitle("LOC", forState: .Normal)
    positionButton.addTarget(self, action: "goToPosition", forControlEvents: .TouchUpInside)
    positionButton.sizeToFit()
    view.addSubview(positionButton)
    positionButtonMargin = try! view.addConstraint("V:[pos]-10-|", forViews: ["pos": positionButton])
    view.addConstraints("H:|-10-[pos]", forViews: ["pos": positionButton])
    
    positionView = UIImageView(image: UIImage(named: "current-position-compas"))
    mapView.currentPositionView = positionView
    positionView2 = UIImageView(image: UIImage(named: "current-position-compas"))

    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.startUpdatingHeading()
  }
  
  override func viewWillAppear(animated: Bool) {
    if let region = session.currentRegion {
      if region.item().name != positionInitiatedFromRegion?.item().name {
        positionInitiatedFromRegion = region
        let coordinates = CLLocationCoordinate2DMake(region.listing.latitude, region.listing.longitude)

        switch region.item().category {
        case Region.Category.COUNTRY.rawValue:
          mapView.visibleRegion = SKCoordinateRegion(center: coordinates, zoomLevel: 5)
        case Region.Category.SUB_REGION.rawValue:
          mapView.visibleRegion = SKCoordinateRegion(center: coordinates, zoomLevel: 11)
        case Region.Category.CITY.rawValue:
          mapView.visibleRegion = SKCoordinateRegion(center: coordinates, zoomLevel: 12)
        case Region.Category.NEIGHBOURHOOD.rawValue:
          mapView.visibleRegion = SKCoordinateRegion(center: coordinates, zoomLevel: 13)
        default:
          try! { throw Error.RuntimeError("Category not supported: \(region.item().category)") }()
        }
        loadMapPOIs()
      }
    }
  }

  
  func degreesToRadians(degrees: CGFloat) -> CGFloat {
    return degrees / 180.0 * CGFloat(M_PI)
  }

  
  func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    let heading = CGFloat(newHeading.magneticHeading)
    positionView.transform = CGAffineTransformMakeRotation(degreesToRadians(heading))
    positionView2.transform = CGAffineTransformMakeRotation(degreesToRadians(heading))
    let head: Int = Int(heading)
    if head % 2 == 0 {
      mapView.currentPositionView = positionView2
    }
    else {
      mapView.currentPositionView = positionView
      
    }
  }
  
  func goToPosition() {
    let region = SKCoordinateRegion(center: SKPositionerService.sharedInstance().currentCoordinate, zoomLevel: mapView.visibleRegion.zoomLevel)
    mapView.visibleRegion = region
  }
  
  func addCircle(latitude: Double, longitude: Double) {
    print("Adding circle at: \(latitude), \(longitude)")
    let circle: SKCircle = SKCircle()
    circle.centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude)
    circle.radius = 100;
    circle.fillColor = UIColor(red: 244/255.0 , green: 71/255.0, blue: 140/255.0, alpha: 0.4)
    circle.strokeColor = UIColor(red: 244/255.0 , green: 71/255.0, blue: 140/255.0, alpha: 0.4)
    circle.isMask = false
    circle.identifier = 300
    mapView.addCircle(circle)
  }
  
  func addAnnotations() {
    
    mapView.clearAllAnnotations()

    var likedListings = 0
    let annotations = annotationService.getAnnotations(pois, mapView: mapView, selectedPoi: calloutView?.currentPoi)
    for annotation in annotations {
      let animationSettings = SKAnimationSettings()
      mapView.addAnnotation(annotation, withAnimationSettings: animationSettings)
      if annotation.annotationView.reuseIdentifier.containsString("liked") {
        likedListings += 1
      }
    }
    print("There were \(likedListings) liked listings.")
    mapView.accessibilityValue = String(likedListings)
  }
  
  func mapView(mapView: SKMapView!, didSelectAnnotation annotation: SKAnnotation!) {
    poiUnselected()

    print("Tapped on annotation")
    
    annotationSelected(annotation)
  }
  
  func annotationSelected(annotation: SKAnnotation) {
    let updatedAnnotations = annotationService.annotationSelected(annotation)
    for updatedAnnotation in updatedAnnotations {
      mapView.updateAnnotation(updatedAnnotation)
    }
    let pois = annotationService.selectedPois()
    calloutView = AnnotationCalloutView(pois: pois) { poi in
      let failure = {
        fatalError("Not designed to fail.")
      }
      ContentService.getListingWithId(poi.listingId, failure: failure) {
        listing in
        
        let vc = DetailController(session: self.session, searchDelegate: self)
        vc.listing = listing
        self.navigationController!.pushViewController(vc, animated: true)
      }
    }
    view.addSubview(calloutView)
    let views = ["callout": calloutView!]
    view.addConstraints("H:|-10-[callout]-10-|", forViews: views)
    view.addConstraints("V:[callout]-10-|", forViews: views)
    print("Added callout view")
    positionButtonMargin.constant = 60
  }
  
  
  func poiUnselected() {
    if calloutView != nil {
      let updatedAnnotations = annotationService.poiUnselected()
      for updatedAnnotation in updatedAnnotations {
        mapView.updateAnnotation(updatedAnnotation)
      }

      calloutView.removeFromSuperview()
      calloutView = nil
      positionButtonMargin.constant = 10
    }
  }
  
  // Manually check if an annotation was tapped.
  func mapView(mapView: SKMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
    poiUnselected()
    print("Tapped on map at \(coordinate)")
    let clickedPoint = mapView.pointForCoordinate(coordinate)
    let zoomLevel = Int(mapView.visibleRegion.zoomLevel)
    if zoomLevel < 12 {
      let annotations = mapView.annotations as! [SKAnnotation]
      for annotation in annotations {
        let annotationPoint = mapView.pointForCoordinate(annotation.location)
        let xDiff = abs(Int32(clickedPoint.x - annotationPoint.x))
        let yDiff = abs(Int32(clickedPoint.y - (annotationPoint.y - 18)))
        if xDiff < 18 && yDiff < 18 {
          annotationSelected(annotation)
          return
        }
      }
    }
  }
    
  func mapView(mapView: SKMapView!, didEndRegionChangeToRegion region: SKCoordinateRegion) {
    print("Region changed")
    loadMapPOIs()
  }

  func loadMapPOIs() {
    print("mapView.frame: \(mapView.frame)")
    let bottomLeft = mapView.coordinateForPoint(CGPoint(x: 0, y: mapView.frame.maxY))
    print("bottomLeft: \(bottomLeft)")
    
    if bottomLeft.latitude.isNaN {
      NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(2), target: self, selector: "loadMapPOIs", userInfo: nil, repeats: false)
    } else {
      
      let topRight = mapView.coordinateForPoint(CGPoint(x: mapView.frame.maxX, y: 0))
      let zoomLevel = Int(mapView.visibleRegion.zoomLevel)
      print("zoomLevel: \(mapView.visibleRegion.zoomLevel)")
      
      if mapPoisRequest != nil {
        mapPoisRequest.cancel()
      }
      
      if NetworkUtil.connectedToNetwork() { // TODO: This test can fail right after went offline, should retry
        let failure = { () -> () in
          NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(2), target: self, selector: "loadMapPOIs", userInfo: nil, repeats: false)
        }
        mapPoisRequest = ContentService.getPois(bottomLeft, topRight: topRight, zoomLevel: zoomLevel, category: session.currentCategory, failure: failure) {
          searchResults in
          
          self.pois = searchResults
          self.addAnnotations()
        }
      } else {
        pois = DatabaseService.getPois(bottomLeft, topRight: topRight, zoomLevel: zoomLevel, category: session.currentCategory)
        addAnnotations()
      }
    }
  }
}

extension MapController: SearchViewControllerDelegate {
  
  func delay(delay:Double, closure:()->()) {
    dispatch_after(
      dispatch_time(
        DISPATCH_TIME_NOW,
        Int64(delay * Double(NSEC_PER_SEC))
      ),
      dispatch_get_main_queue(), closure)
  }
  
  func selectedSearchResult(searchResult: SimplePOI, failure: () -> (), stopSpinner: () -> ()) {
    
//    let promise = Promise<String, NoError>()
//    if String(searchResult.resultType).hasPrefix("2") { // attraction
//      ContentService.getListingWithId(searchResult.listingId!) {
//        attraction in
//        
//        self.currentListing = attraction
//        
//        promise.future.onComplete() { _ in
//          self.performSegueWithIdentifier("showDetail", sender: attraction)
//        }
//      }
//    }
    
    stopSpinner()
    dismissViewControllerAnimated(true, completion: nil)
    print("Going to location of search result")
    var delayTime = 0.1
    if !mapView.isLocationVisible(searchResult.latitude, long: searchResult.longitude) {
      mapView.animateToLocation(CLLocationCoordinate2DMake(searchResult.latitude, searchResult.longitude), withDuration: 1.0)
      delayTime = 1.1
    }
    
    let oldZoomLevel = mapView.visibleRegion.zoomLevel
    var newZoomLevel = 15
    var putAnnotation = true
    print("select a search result with category: \(searchResult.category)")
    if searchResult.category == Region.Category.COUNTRY.rawValue {
      newZoomLevel = 6
      putAnnotation = false
    }
    if (newZoomLevel == 15 && oldZoomLevel < 14) || (newZoomLevel == 6 && oldZoomLevel > 7) {
      mapView.animateToZoomLevel(Float(newZoomLevel))
      mapView.animateToLocation(CLLocationCoordinate2DMake(searchResult.latitude, searchResult.longitude), withDuration: 1.0)
      delayTime = 1.1
    }
    if putAnnotation {
//      selectedPoi = searchResult
    }
//    delay(delayTime) {
//      promise.success("Waited")
//    }   
  }
  
  func navigateToSearch() {
    let nav = UINavigationController()
    let regionId = session.currentRegion?.getId()
    let countryId = session.currentCountry?.getId()
    let searchController = SearchController(delegate: self, regionId: regionId, countryId: countryId)
    nav.viewControllers = [searchController]
    presentViewController(nav, animated: true, completion: nil)
  }
}