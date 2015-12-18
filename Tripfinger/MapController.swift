import SKMaps
import RealmSwift
import BrightFutures

class MapController: UIViewController, SubController, SKMapViewDelegate, CLLocationManagerDelegate, SKPositionerServiceDelegate {
  
  var session: Session!
  var currentAttraction: Attraction!
  var attractions = List<Attraction>()
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
    languageSettings.primaryInternationalLanguage = SKLanguage.MapLanguageES
    languageSettings.fallbackInternationalLanguage = SKLanguage.MapLanguageTR
    languageSettings.primaryOption = SKMapInternationalizationOption.International
    languageSettings.fallbackOption = SKMapInternationalizationOption.Transliterated
    languageSettings.showBothOptions = true
    mapView.settings.mapInternationalization = languageSettings

    mapView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
    mapView.delegate = self
    mapView.settings.rotationEnabled = true
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
    
//    print(view.subviews.count)
//    for subview in view.subviews {
//      print (subview)
//      for subsub in subview.subviews {
//        if subsub.tag == 100 {
//          print("  \(subsub)")
//          let aMirror = Mirror(reflecting: subsub)
//          
//          func methods(t: AnyObject, inout count : CUnsignedInt) -> UnsafeMutablePointer<Method> {
//            return class_copyMethodList(object_getClass(t), &count)
//          }
//
//          func methods_cls(t: AnyClass, inout count : CUnsignedInt) -> UnsafeMutablePointer<Method> {
//            return class_copyMethodList(t, &count)
//          }
//
//          var numClasses = objc_getClassList(nil, 0)
//          
//          var testClass: AnyClass! = nil
//          let classes = AutoreleasingUnsafeMutablePointer<AnyClass?>(malloc(Int(sizeof(AnyClass) * Int(numClasses))))
//          numClasses = objc_getClassList(classes, numClasses)
//          
//          var resultos = [AnyClass]()
//          
//          for i in 0..<numClasses {
//            let superClass: AnyClass! = classes[Int(i)] as AnyClass!
//            
//            if (superClass != nil) {
//              resultos.append(classes[Int(i)]!)
//              print(String.fromCString(class_getName(superClass)))
//              if String.fromCString(class_getName(superClass))! == "GEOPDLocalizedAddress" {
//                testClass = superClass
//              }
//            }
//          }
//          
//          let f: ()->() = {
//            print("test")
//          }
//          let imp = imp_implementationWithBlock(
//            unsafeBitCast(
//              f as @convention(block) ()->(),
//              AnyObject.self
//            )
//          )
          
//          class_replaceMethod(testClass, Selector("setAddress:"), imp, 
          
//          func arguments(m: Method) -> String? {
//            let arg = method_copyArgumentType(m, 2)
//            let data = NSData(bytes: arg, length: Int(strlen(arg)))
//            let str = NSString(data: data, encoding: NSUTF8StringEncoding)
//            return String(str)
////            let pointer = UnsafeMutablePointer<Int8>()
////            let length = 0
////            method_getArgumentType(m, 0, pointer, length)
////            return String.fromCString(pointer)
//          }
          
//          var i=0
//          var mc : CUnsignedInt = 0
//          let mlist = methods(subsub, count: &mc)
//          let n : Int = Int(mc)
//          for (i=0; i<n;i++) {
//            print(method_getName(mlist[i]))
////            print(arguments(mlist[i]))
//          }
//          subsub.setValue(20.0, forKey: "compassOffset")
//          subsub.setValue(false, forKey: "showCurrentPosition")
//          subsub.setValue(true, forKey: "showCompass")
//          subsub.setValue(true, forKey: "showStreetNamePopUps")
//          subsub.setValue(true, forKey: "showStreetBadges")
//          subsub.setValue(languageSettings, forKey: "mapInternationalization")
//          let result = subsub.performSelector(Selector("setCompassOffset:"), withObject: 20.0)
//          print("result: \(result)")
//          print(subsub.valueForKey("mapInternationalization"))
//          print(subsub.valueForKey("compassOffset"))
//          
//          self.setValue(89, forKey: "test")
//          print("ANSWER: \(test)")
//          
//          let mlist2 = methods_cls(testClass, count: &mc)
//          let m = Int(mc)
//          for (i=0; i<m;i++) {
//            print(method_getName(mlist2[i]))
//            //            print(arguments(mlist[i]))
//          }

//        }
//        for subsubsub in subsub.subviews {
//          print("    \(subsubsub)")
//        }
//      }
//    }
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
    
    if currentAttraction != nil {
      return
    }
    
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
    
    print("Tapped on annotation")
    
    var attraction = currentAttraction
    if annotation.identifier != 5000 {
      attraction = attractions[Int(annotation.identifier)]
    }
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
    
    print("Tapped on map")
    
    mapView.hideCallout()
    if currentAttraction != nil {
      currentAttraction = nil
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
  
  // from search
  func regionChanged(regionId: String) {
  }
}

extension MapController: SKCalloutViewDelegate {
  
  func calloutView(calloutView: SKCalloutView!, didTapRightButton rightButton: UIButton!) {
    let attraction = attractions[calloutView.titleLabel.tag - 2000]
    performSegueWithIdentifier("showDetail", sender: attraction)
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
  
  func selectedSearchResult(searchResult: SearchResult, afterTransition: (() -> ())?) {
    
    currentAttraction = Attraction()
    let promise = Promise<String, NoError>()
    if String(searchResult.resultType).hasPrefix("2") { // attraction
      ContentService.getAttractionWithId(searchResult.listingId!) {
        attraction in
        
        self.currentAttraction = attraction
        
        promise.future.onComplete() { _ in
          self.performSegueWithIdentifier("showDetail", sender: attraction)
        }
      }
    }
    
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
    delay(delayTime) {
      promise.success("Waited")
    }   
  }
}