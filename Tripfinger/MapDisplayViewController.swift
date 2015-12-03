import SKMaps
import RealmSwift

class MapDisplayViewController: UIViewController, SubController, SKMapViewDelegate, CLLocationManagerDelegate, SKPositionerServiceDelegate {
  
  var session: Session!
  var attractions = List<Attraction>()
  var mapView: SKMapView!
  var locationManager: CLLocationManager!
  var positionView: UIImageView!
  var positionView2: UIImageView!
  var previousHeading: CGFloat = 0.0
  
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    
    mapView = SKMapView(frame: CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)))
    let languageSettings = SKMapInternationalizationSettings.mapInternationalization()
    languageSettings.backupToTransliterated = false
    languageSettings.primaryInternationalLanguage = SKLanguage.MapLanguageEN
    languageSettings.fallbackInternationalLanguage = SKLanguage.MapLanguageDE
    languageSettings.primaryOption = SKMapInternationalizationOption.International
    languageSettings.fallbackOption = SKMapInternationalizationOption.Transliterated
    mapView.settings.mapInternationalization = languageSettings

    mapView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
    mapView.delegate = self
    mapView.settings.rotationEnabled = false
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
    
    if (session.currentAttractions.count > 0) {
      attractions = session.currentAttractions
      addAnnotations()
    }
    else {
      loadAttractions()
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
  
  func loadAttractions() {
    
    session.loadAttractions() {
      loaded in
      
      self.attractions = self.session.currentAttractions
      self.addAnnotations()
    }
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
    
    var identifier: Int32 = 0
    for attraction in attractions {
      let annotation = SKAnnotation()
      annotation.identifier = identifier
      if attraction.swipedRight != nil && attraction.swipedRight! {
        annotation.annotationType = SKAnnotationType.Blue
      }
      else {
        annotation.annotationType = SKAnnotationType.Purple
      }
      annotation.location = CLLocationCoordinate2DMake(attraction.listing.latitude, attraction.listing.longitude)
      let animationSettings = SKAnimationSettings()
      mapView.addAnnotation(annotation, withAnimationSettings: animationSettings)
      identifier += 1
    }
  }
  
  func mapView(mapView: SKMapView!, didSelectAnnotation annotation: SKAnnotation!) {
    let attraction = attractions[Int(annotation.identifier)]
    mapView.calloutView.titleLabel.text = attraction.listing.item.name;
    mapView.calloutView.titleLabel.tag = 2000 + Int(annotation.identifier)
    mapView.calloutView.delegate = self
    mapView.calloutView.minZoomLevel = 1
    mapView.showCalloutForAnnotation(annotation, withOffset: CGPointMake(0, 42), animated: true);
  }
  
  func mapView(mapView: SKMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
    if mapView.visibleRegion.zoomLevel < 12 {
      // Manually check if an annotation was tapped.
    }
    
    mapView.hideCallout()
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showDetail" {
      let detailController = segue.destinationViewController as! DetailController
      detailController.attraction = sender as! Attraction
      detailController.imagePath = detailController.attraction.getImagePath(session.currentRegion!)
    }
  }
}

extension MapDisplayViewController: SKCalloutViewDelegate {
  
  func calloutView(calloutView: SKCalloutView!, didTapRightButton rightButton: UIButton!) {
    let attraction = attractions[calloutView.titleLabel.tag - 2000]
    performSegueWithIdentifier("showDetail", sender: attraction)
  }
}

extension MapDisplayViewController: SearchViewControllerDelegate {
  
  func selectedSearchResult(searchResult: SearchResult) {
    if !mapView.isLocationVisible(searchResult.latitude, long: searchResult.longitude) {
      let location = CLLocationCoordinate2DMake(searchResult.latitude, searchResult.longitude)
      mapView.animateToLocation(location, withDuration: 1.0)
    }
    if mapView.visibleRegion.zoomLevel < 14 {
      mapView.animateToZoomLevel(15)
      let location = CLLocationCoordinate2DMake(searchResult.latitude, searchResult.longitude)
      mapView.animateToLocation(location, withDuration: 1.0)
    }
    //        addCircle(searchResult.latitude, longitude: searchResult.longitude)
    let annotation = SKAnnotation()
    annotation.identifier = 5000
    annotation.annotationType = SKAnnotationType.Green
    annotation.location = CLLocationCoordinate2DMake(searchResult.latitude, searchResult.longitude)
    let animationSettings = SKAnimationSettings()
    animationSettings.animationType = SKAnimationType.AnimationPinDrop
    mapView.addAnnotation(annotation, withAnimationSettings: animationSettings)
    
  }
}