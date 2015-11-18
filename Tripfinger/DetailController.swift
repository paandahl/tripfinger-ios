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
        
        name.text = attraction.name
        descriptionText.text = attraction.content
        mainImage.image = UIImage(named: "Placeholder")
        mainImage.loadImageWithUrl(attraction.images[0].url)
    }
}