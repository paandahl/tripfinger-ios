//
//  UIView+AddConstraints.swift
//  Tripfinger
//
//  Created by Preben Ludviksen on 11/10/15.
//  Copyright (c) 2015 Preben Ludviksen. All rights reserved.
//

import Foundation

let customPriority = Float(999)

extension UIView {
  
  
  func addConstraints(constraints: String, forViews views: [String : UIView]) -> [NSLayoutConstraint] {
    
    for (_, view) in views {
      view.translatesAutoresizingMaskIntoConstraints = false
    }
    let constraints = NSLayoutConstraint.constraintsWithVisualFormat(constraints, options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: views)
    for constraint in constraints {
      constraint.priority = customPriority
    }

    self.addConstraints(constraints)
    return constraints
  }
  
  func addConstraint(constraints: String, forViews views: [String : UIView]) throws -> NSLayoutConstraint {
    
    let consts = addConstraints(constraints, forViews: views)
    if consts.count != 1 {
      throw Error.RuntimeError("Added more than one constraint.")
    }
    return consts[0]
  }


  func addConstraintsArray(constraintsArray: [String], forViews views: [String : UIView]) -> [NSLayoutConstraint] {
    
    for (_, view) in views {
      view.translatesAutoresizingMaskIntoConstraints = false
    }
    var constraintsObjects = [NSLayoutConstraint]()
    for constraints in constraintsArray {
      let constraintsObs = NSLayoutConstraint.constraintsWithVisualFormat(constraints, options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: views)
      for constraintsObj in constraintsObs {
        constraintsObj.priority = customPriority
      }
      self.addConstraints(constraintsObs)
      constraintsObjects.appendContentsOf(constraintsObs)
    }
    return constraints
  }

  func addConstraint(alignmentConstraint: NSLayoutAttribute, forView view: UIView) -> NSLayoutConstraint {
    
    view.translatesAutoresizingMaskIntoConstraints = false
    let centerConstraint = NSLayoutConstraint(
      item: view,
      attribute: alignmentConstraint,
      relatedBy: NSLayoutRelation.Equal,
      toItem: self,
      attribute: alignmentConstraint,
      multiplier: 1.0,
      constant: 0);
    centerConstraint.priority = customPriority
    self.addConstraint(centerConstraint)
    return centerConstraint
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
      centerConstraint.priority = customPriority
      self.addConstraint(centerConstraint)
    }
    
  }
  
  func removeAllConstraints() {
    UIView.removeAllConstraints(self)
  }
  
  class func removeAllConstraints(view: UIView) {
    view.removeConstraints(view.constraints)
    for subview in view.subviews {
      removeAllConstraints(subview)
    }
  }
}