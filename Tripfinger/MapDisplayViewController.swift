//
//  ViewController.swift
//  TripFinger
//
//  Created by Preben Ludviksen on 06/09/15.
//  Copyright (c) 2015 Preben Ludviksen. All rights reserved.
//

import SKMaps
class MapDisplayViewController: UIViewController, SubController, SKMapViewDelegate {
  
  var session: Session!
  var attractions = [Attraction]()
  var mapView: SKMapView!
  
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    mapView = SKMapView(frame: CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)))
    mapView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
    mapView.delegate = self
    mapView.settings.rotationEnabled = false
    mapView.settings.orientationIndicatorType = SKOrientationIndicatorType.CustomImage
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
    
    self.view.addSubview(mapView)
    
    if (session.currentAttractions.count > 0) {
      attractions = session.currentAttractions
      addAnnotations()
    }
    else {
      loadAttractions()
    }
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
      annotation.location = CLLocationCoordinate2DMake(attraction.latitude, attraction.longitude)
      let animationSettings = SKAnimationSettings()
      mapView.addAnnotation(annotation, withAnimationSettings: animationSettings)
      identifier += 1
    }
  }
  
  func mapView(mapView: SKMapView!, didSelectAnnotation annotation: SKAnnotation!) {
    let attraction = attractions[Int(annotation.identifier)]
    mapView.calloutView.titleLabel.text = attraction.name;
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