import SKMaps
import RealmSwift
import BrightFutures

class MapController: UIViewController, SubController, SKMapViewDelegate, CLLocationManagerDelegate, SKPositionerServiceDelegate {
  
  var session: Session!
  var currentPoi: SearchResult!
  var pois = List<SearchResult>()
  var mapView: SKMapView!
  var locationManager: CLLocationManager!
  var positionView: UIImageView!
  var positionView2: UIImageView!
  var previousHeading: CGFloat = 0.0
  var test: Int = 45
  
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    
    mapView = SKMapView(frame: CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)))
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
    
    // second digit of first coordinate - higher means south, lower means north
    // second digit of second coordinate - higher means west, lower means east
    
    let lat = 50.847031 // Brussels
    let long = 4.353559
    //        let lat = 41.39479 // Barcelona
    //        let long = 2.1487679
    let coordinates = CLLocationCoordinate2DMake(lat, long)
    
    let region = SKCoordinateRegion(center: coordinates, zoomLevel: 14)
    mapView.visibleRegion = region
    
    view.addSubview(mapView)
    
    let positionButton = UIButton(type: .System)
    let positionButtonImage = UIImage(named: "ic_geoposition")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
    positionButton.setImage(positionButtonImage, forState: .Normal)
//    positionButton.setTitle("LOC", forState: .Normal)
    positionButton.addTarget(self, action: "goToPosition", forControlEvents: .TouchUpInside)
    positionButton.sizeToFit()
    view.addSubview(positionButton)
    view.addConstraints("V:[pos]-20-|", forViews: ["pos": positionButton])
    view.addConstraints("H:|-20-[pos]", forViews: ["pos": positionButton])
    
    
    positionView = UIImageView(image: UIImage(named: "current-position-compas"))
    mapView.currentPositionView = positionView
    positionView2 = UIImageView(image: UIImage(named: "current-position-compas"))

    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.startUpdatingHeading()
    
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
    
    if currentPoi != nil {
      return
    }
    
    mapView.clearAllAnnotations()
    
    print("adding annotations for \(pois.count) pois")
    
    var identifier: Int32 = 0
    for poi in pois {
      let annotation = SKAnnotation()
      annotation.identifier = identifier
//      if attraction.swipedRight != nil && attraction.swipedRight! {
//        annotation.annotationType = SKAnnotationType.Blue
//      }
//      else {
//        annotation.annotationType = SKAnnotationType.Purple
//      }
      if poi.category == 2392 {
        if mapView.visibleRegion.zoomLevel < 12 {
          identifier += 1
          continue
        }
        let coloredView = UIImageView(frame: CGRectMake(0.0, 0.0, 12.0, 12.0))
        coloredView.image = UIImage(named: "subway-m")
        let view = SKAnnotationView(view: coloredView, reuseIdentifier: "viewID")
        annotation.annotationView = view
      }
      else if poi.category == 2393 {
        if mapView.visibleRegion.zoomLevel < 15 {
          identifier += 1
          continue
        }
        let coloredView = UIImageView(frame: CGRectMake(0.0, 0.0, 12.0, 12.0))
        coloredView.image = UIImage(named: "subway-entrance-m")
        let view = SKAnnotationView(view: coloredView, reuseIdentifier: "viewID2")
        annotation.annotationView = view
      }
      annotation.location = CLLocationCoordinate2DMake(poi.latitude, poi.longitude)
      let animationSettings = SKAnimationSettings()
      mapView.addAnnotation(annotation, withAnimationSettings: animationSettings)
      identifier += 1
    }
  }
  
  func mapView(mapView: SKMapView!, didSelectAnnotation annotation: SKAnnotation!) {
    
    print("Tapped on annotation")
    
    var poi = currentPoi
    if annotation.identifier != 5000 {
      poi = pois[Int(annotation.identifier)]
    }
    mapView.calloutView.titleLabel.text = poi.name;
    mapView.calloutView.titleLabel.tag = 2000 + Int(annotation.identifier)
    mapView.calloutView.delegate = self
    mapView.calloutView.minZoomLevel = 1
    mapView.showCalloutForAnnotation(annotation, withOffset: CGPointMake(0, 42), animated: true);
  }
  
  func mapView(mapView: SKMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
    if mapView.visibleRegion.zoomLevel < 12 {
      // Manually check if an annotation was tapped.
    }
    
    print("Tapped on map")
    
    mapView.hideCallout()
    if currentPoi != nil {
      currentPoi = nil
      addAnnotations()
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showDetail" {
      let detailController = segue.destinationViewController as! DetailController
      detailController.attraction = sender as! Attraction
      detailController.imagePath = detailController.attraction.getLocalImagePath()
    }
  }
  
  func mapView(mapView: SKMapView!, didEndRegionChangeToRegion region: SKCoordinateRegion) {
    print("Region changed")
    let bottomLeftCoord = mapView.coordinateForPoint(CGPoint(x: 0, y: mapView.frame.maxY))
    let topRightCoord = mapView.coordinateForPoint(CGPoint(x: mapView.frame.maxX, y: 0))
    print("zoomLevel: \(mapView.visibleRegion.zoomLevel)")
    loadMapPOIs(bottomLeftCoord, topRight: topRightCoord)
  }

  func loadMapPOIs(bottomLeft: CLLocationCoordinate2D, topRight: CLLocationCoordinate2D) {
    ContentService.getPois(bottomLeft, topRight: topRight) {
      searchResults in
      
      self.pois = searchResults
      self.addAnnotations()
    }
  }
}

extension MapController: SKCalloutViewDelegate {
  
  func calloutView(calloutView: SKCalloutView!, didTapRightButton rightButton: UIButton!) {
    let poi = pois[calloutView.titleLabel.tag - 2000]
//    performSegueWithIdentifier("showDetail", sender: attraction)
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
  
  func selectedSearchResult(searchResult: SearchResult) {
    
    currentPoi = searchResult
//    let promise = Promise<String, NoError>()
//    if String(searchResult.resultType).hasPrefix("2") { // attraction
//      ContentService.getAttractionWithId(searchResult.listingId!) {
//        attraction in
//        
//        self.currentAttraction = attraction
//        
//        promise.future.onComplete() { _ in
//          self.performSegueWithIdentifier("showDetail", sender: attraction)
//        }
//      }
//    }
    
    print("Going to location of search result")
    var delayTime = 0.1
    if !mapView.isLocationVisible(searchResult.latitude, long: searchResult.longitude) {
      let location = CLLocationCoordinate2DMake(searchResult.latitude, searchResult.longitude)
      mapView.animateToLocation(location, withDuration: 1.0)
      delayTime = 1.1
    }
    if mapView.visibleRegion.zoomLevel < 14 {
      mapView.animateToZoomLevel(15)
      let location = CLLocationCoordinate2DMake(searchResult.latitude, searchResult.longitude)
      mapView.animateToLocation(location, withDuration: 1.0)
      delayTime = 1.1
    }
    //        addCircle(searchResult.latitude, longitude: searchResult.longitude)
    mapView.clearAllAnnotations()
    let annotation = SKAnnotation()
    annotation.identifier = 5000
    annotation.annotationType = SKAnnotationType.Green
    annotation.location = CLLocationCoordinate2DMake(searchResult.latitude, searchResult.longitude)
    let animationSettings = SKAnimationSettings()
    animationSettings.animationType = SKAnimationType.AnimationPinDrop
    mapView.addAnnotation(annotation, withAnimationSettings: animationSettings)
//    delay(delayTime) {
//      promise.success("Waited")
//    }   
  }
}