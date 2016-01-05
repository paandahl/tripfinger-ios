import SKMaps
import RealmSwift
import BrightFutures

class MapController: UIViewController, SubController, SKMapViewDelegate, CLLocationManagerDelegate, SKPositionerServiceDelegate {
  
  var session: Session!
  var selectedPoi: SearchResult!
  var selectedAnnotation: SKAnnotation!
  var calloutView: AnnotationCalloutView!
  var positionButtonMargin: NSLayoutConstraint!
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
    //    let coordinates = CLLocationCoordinate2DMake(lat, long)
//    
//    let region = SKCoordinateRegion(center: coordinates, zoomLevel: 14)
//    mapView.visibleRegion = region
    
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
    
    print("adding annotations for \(pois.count) pois")
    
    var identifier: Int32 = 0
    for poi in pois {
      let selected = selectedPoi != nil &&
        (poi.coordinates.latitude == selectedPoi.coordinates.latitude &&
          poi.coordinates.longitude == selectedPoi.coordinates.longitude)
      if !selected && isPoiHidden(poi) {
        identifier += 1
        continue
      }
      let annotation = SKAnnotation()
      annotation.identifier = identifier

      if poi.category == 2392 {
        annotation.annotationView = getAnnotationViewWithIcon("subway-m", selected: selected)
      }
      else if poi.category == 2393 {
        annotation.annotationView = getAnnotationViewWithIcon("subway-entrance-m", selected: selected)
      }
      else {
        annotation.annotationType = selected ? SKAnnotationType.Green : SKAnnotationType.Blue
      }
      annotation.location = poi.coordinates
      let animationSettings = SKAnimationSettings()
      mapView.addAnnotation(annotation, withAnimationSettings: animationSettings)
      if selected {
        selectedAnnotation = annotation
      }
      identifier += 1
    }
  }
  
  func getAnnotationViewWithIcon(named: String, selected: Bool) -> SKAnnotationView {
    let annotationView = UIView(frame: CGRectMake(0, 0, 14, 14))
    annotationView.backgroundColor = selected ? UIColor.greenColor() : UIColor.whiteColor()
    annotationView.layer.cornerRadius = 7
    let imageView = UIImageView(frame: CGRectMake(1, 1, 12, 12))
    imageView.image = UIImage(named: named)
    annotationView.addSubview(imageView)
    let reuseIdentifier = selected ? "\(named)-selected" : named
    return SKAnnotationView(view: annotationView, reuseIdentifier: reuseIdentifier)
  }

  
  func isPoiHidden(poi: SearchResult) -> Bool {
    let zoomLevel = mapView.visibleRegion.zoomLevel
    return (poi.category == 2392 && zoomLevel < 12) || (poi.category == 2393 && zoomLevel < 15) || String(poi.category).hasPrefix("1")
  }
  
  func mapView(mapView: SKMapView!, didSelectAnnotation annotation: SKAnnotation!) {
    poiUnselected()

    print("Tapped on annotation")
    
    let poi = pois[Int(annotation.identifier)]
    poiSelected(annotation, poi: poi)
  }
  
  func poiSelected(annotation: SKAnnotation, poi: SearchResult) {
    if poi.listingId == "simple" {
      annotation.annotationView = getAnnotationViewWithIcon(annotation.annotationView.reuseIdentifier, selected: true)
    }
    else {
      annotation.annotationType = SKAnnotationType.Green
    }
    mapView.updateAnnotation(annotation)
    selectedAnnotation = annotation
    selectedPoi = poi
    calloutView = AnnotationCalloutView(poi: poi) {
      ContentService.getAttractionWithId(poi.listingId) {
        attraction in
        
        self.performSegueWithIdentifier("showDetail", sender: attraction)
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
      if selectedPoi.listingId == "simple" {
        let reuseIdentifier = selectedAnnotation.annotationView.reuseIdentifier
        let index = reuseIdentifier.endIndex.advancedBy(-9)
        let iconName = reuseIdentifier.substringToIndex(index)
        selectedAnnotation.annotationView = getAnnotationViewWithIcon(iconName, selected: false)
      }
      else {
        selectedAnnotation.annotationType = SKAnnotationType.Blue
      }
      mapView.updateAnnotation(selectedAnnotation)
      selectedAnnotation = nil
      selectedPoi = nil

      calloutView.removeFromSuperview()
      calloutView = nil
      positionButtonMargin.constant = 10
    }
  }
  
  func mapView(mapView: SKMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
    poiUnselected()
    print("Tapped on map at \(coordinate)")
    let clickedPoint = mapView.pointForCoordinate(coordinate)
    if mapView.visibleRegion.zoomLevel < 12 {
      var i = 0
      for poi in pois {
        
        if isPoiHidden(poi) {
          i += 1
          continue
        }
        let poiPoint = mapView.pointForCoordinate(poi.coordinates)
//        let label = UILabel(frame: CGRectMake(poiPoint.x - 18, poiPoint.y - 36, 36, 36))
//        label.backgroundColor = UIColor.greenColor()
//        view.addSubview(label)
        let xDiff = abs(Int32(clickedPoint.x - poiPoint.x))
        let yDiff = abs(Int32(clickedPoint.y - (poiPoint.y - 18)))
        if xDiff < 18 && yDiff < 18 {
          let annotation = mapView.annotationForIdentifier(Int32(i))
          poiSelected(annotation, poi: poi)
          return
        }
        i += 1
      }
      // Manually check if an annotation was tapped.
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
    if !mapView.isLocationVisible(searchResult.coordinates.latitude, long: searchResult.coordinates.longitude) {
      mapView.animateToLocation(searchResult.coordinates, withDuration: 1.0)
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
      mapView.animateToLocation(searchResult.coordinates, withDuration: 1.0)
      delayTime = 1.1
    }
    if putAnnotation {
      selectedPoi = searchResult
    }
//    delay(delayTime) {
//      promise.success("Waited")
//    }   
  }
}