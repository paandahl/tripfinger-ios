//
//  DetailController.swift
//  Tripfinger
//
//  Created by Preben Ludviksen on 23/10/15.
//  Copyright © 2015 Preben Ludviksen. All rights reserved.
//

import Foundation

class DetailController: UIViewController {
  
  @IBOutlet weak var mainImage: UIImageView!
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var descriptionText: UITextView!
  
  var attraction: Attraction!
  
  override func viewDidLoad() {
    
    name.text = attraction.listing.item.name
    descriptionText.text = attraction.listing.item.content
    
    if attraction.item().offline {
      mainImage.contentMode = UIViewContentMode.ScaleAspectFill
      print("fetching image from \(attraction.item().images[0].getFileUrl())")
      mainImage.image = UIImage(data: NSData(contentsOfURL: attraction.item().images[0].getFileUrl())!)
    }
    else {
      mainImage.image = UIImage(named: "Placeholder")
      try! mainImage.loadImageWithUrl(attraction.item().images[0].url)
    }

  }
}