//
//  FilterBox.swift
//  Tripfinger
//
//  Created by Preben Ludviksen on 28/10/15.
//  Copyright © 2015 Preben Ludviksen. All rights reserved.
//

import Foundation

protocol FilterBoxDelegate: class {
  func filterClick()
}

class FilterBox: UIView {
  
  @IBOutlet weak var filterControls: UIView!
  @IBOutlet weak var regionNameLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  
  var delegate: FilterBoxDelegate!
  
  override func awakeFromNib() {
    filterControls.layer.borderColor = UIColor.darkGrayColor().CGColor
    filterControls.layer.borderWidth = 0.5;
    
    let singleTap = UITapGestureRecognizer(target: self, action: "filterClick")
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    filterControls.addGestureRecognizer(singleTap)
    filterControls.userInteractionEnabled = true
    
    
  }
  
  func filterClick() {
    delegate.filterClick()
  }
  
}