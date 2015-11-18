//
//  ListingCell.swift
//  Tripfinger
//
//  Created by Preben Ludviksen on 23/10/15.
//  Copyright © 2015 Preben Ludviksen. All rights reserved.
//

import Foundation

protocol ListingCellContainer: class {
  func showDetail(attraction: Attraction)
}

class ListingCell: UITableViewCell {
  
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var mainImage: UIImageView!
  @IBOutlet weak var heartImage: UIImageView!
  var attraction: Attraction!
  var delegate: ListingCellContainer!
  
  override func awakeFromNib() {
    let singleTap = UITapGestureRecognizer(target: self, action: "imageClick:")
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    mainImage.addGestureRecognizer(singleTap)
    mainImage.userInteractionEnabled = true
    heartImage.image = heartImage.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
  }
  
  func setContent(attraction: Attraction) {
    name.text = attraction.name
    mainImage.image = UIImage(named: "Placeholder")
    if attraction.swipedRight != nil && attraction.swipedRight! {
      heartImage.tintColor = UIColor.redColor()
    }
    else {
      heartImage.tintColor = UIColor.darkGrayColor()
    }
    let imageUrl = attraction.images[0].url + "-712x534"
    mainImage.loadImageWithUrl(imageUrl)
    self.attraction = attraction
  }
  
  func imageClick(sender: UIImageView) {
    delegate.showDetail(attraction)
  }
}