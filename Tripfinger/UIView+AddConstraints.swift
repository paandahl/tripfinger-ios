//
//  UIView+AddConstraints.swift
//  Tripfinger
//
//  Created by Preben Ludviksen on 11/10/15.
//  Copyright (c) 2015 Preben Ludviksen. All rights reserved.
//

import Foundation

extension UIView {
  
  func addConstraints(constraints: String, forViews views: [String : UIView]) -> [NSLayoutConstraint] {
    
    for (_, view) in views {
      view.translatesAutoresizingMaskIntoConstraints = false
    }
    let constraints = NSLayoutConstraint.constraintsWithVisualFormat(constraints, options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: views)
    self.addConstraints(constraints)
    return constraints
  }
  
  func addConstraint(alignmentConstraint: NSLayoutAttribute, forView view: UIView) {
    
    view.translatesAutoresizingMaskIntoConstraints = false
    let centerConstraint = NSLayoutConstraint(
      item: view,
      attribute: alignmentConstraint,
      relatedBy: NSLayoutRelation.Equal,
      toItem: self,
      attribute: alignmentConstraint,
      multiplier: 1.0,
      constant: 0);
    self.addConstraint(centerConstraint)
    
  }
  
  func addMarginConstraintToView(view: UIView, side: NSLayoutAttribute, value: Int, target: UIView?, targetSide: NSLayoutAttribute?) {
    
    view.translatesAutoresizingMaskIntoConstraints = false
    if let target = target {
      let centerConstraint = NSLayoutConstraint(
        item: view,
        attribute: side,
        relatedBy: NSLayoutRelation.Equal,
        toItem: target,
        attribute: targetSide!,
        multiplier: 1.0,
        constant: 0);
      self.addConstraint(centerConstraint)
    }
    
  }
  
}