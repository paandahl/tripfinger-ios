//
//  ViewController.swift
//  TripFinger
//
//  Created by Preben Ludviksen on 06/09/15.
//  Copyright (c) 2015 Preben Ludviksen. All rights reserved.
//

import SKMaps
class MapDisplayViewController : UIViewController, SKMapViewDelegate {

    var session: Session!
    var attractions = [Attraction]()
    var mapView: SKMapView!
 
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        
        let searchBar:UISearchBar = UISearchBar(frame: CGRectMake(0, 0, 200, 20))
        let searchBarItem = UIBarButtonItem(customView: searchBar)
        
        
//        UIBarButtonItem *searchBarItem = [[UIBarButtonItem alloc] initWithCustomView:searchBar];
        self.navigationItem.rightBarButtonItem = searchBarItem;
        
        mapView = SKMapView(frame: CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)))
        mapView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        mapView.delegate = self
        mapView.settings.rotationEnabled = false
        mapView.settings.headingMode = SKHeadingMode.None
        
        // second digit of first coordinate - higher means south, lower means north
        // second digit of second coordinate - higher means west, lower means east
        
        let lat = 50.847031 // Brussels
        let long = 4.353559
//        let lat = 41.39479 // Barcelona
//        let long = 2.1487679
        
        let region = SKCoordinateRegion(center: CLLocationCoordinate2DMake(lat, long), zoomLevel: 14)
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
            self.attractions = self.session.currentAttractions
            self.addAnnotations()
        }
    }

    
    func addAnnotations() {
        
        print("adding annotations")

        var identifier: Int32 = 0
        for attraction in attractions {
            let annotation = SKAnnotation()
            annotation.identifier = identifier
            annotation.annotationType = SKAnnotationType.Purple
            annotation.location = CLLocationCoordinate2DMake(attraction.latitude, attraction.longitude)
            let animationSettings = SKAnimationSettings()
            mapView.addAnnotation(annotation, withAnimationSettings: animationSettings)
            identifier += 1
        }
        
//        annotation.annotationType = SKAnnotationType.DestinationFlag
//        annotation.annotationType = SKAnnotationType.Marker

        //Annotation with view
        //create our view
//        let coloredView = UIImageView(frame: CGRectMake(0.0, 0.0, 30.0, 30.0))
//        coloredView.image = UIImage(named: "image.png")
//        let view = SKAnnotationView(view: coloredView, reuseIdentifier: "viewID")
//        let viewAnnotation = SKAnnotation()
//        viewAnnotation.annotationView = view
//        viewAnnotation.identifier = 100
//        viewAnnotation.location = CLLocationCoordinate2DMake(50.837031, 4.343559)
//        mapView.addAnnotation(viewAnnotation, withAnimationSettings: animationSettings)
    }
    
    func mapView(mapView:SKMapView!, didSelectAnnotation annotation:SKAnnotation!) {
        let attraction = attractions[Int(annotation.identifier)]
        mapView.calloutView.titleLabel.text = attraction.name;
        mapView.showCalloutForAnnotation(annotation, withOffset: CGPointMake(0, 42), animated: true);
    }

    func mapView(mapView: SKMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        mapView.hideCallout()
    }
}