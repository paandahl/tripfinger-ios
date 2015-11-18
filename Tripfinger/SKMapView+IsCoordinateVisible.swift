//
//  SKMapView+IsCoordinateVisible.swift
//  Tripfinger
//
//  Created by Preben Ludviksen on 26/10/15.
//  Copyright © 2015 Preben Ludviksen. All rights reserved.
//

import Foundation

extension SKMapView {
  
  func isLocationVisible(lat: Double, long: Double) -> Bool {
    let margin: CGFloat = 30.0
    
    let coordinates = CLLocationCoordinate2DMake(lat, long)
    let point = self.pointForCoordinate(coordinates)
    
    if point.x < margin || point.y < margin {
      return false
    }
    
    let mainScreen = UIScreen.mainScreen()
    if point.x > (mainScreen.bounds.width - margin) || point.y > (mainScreen.bounds.height - margin) {
      return false
    }
    
    return true
  }
}