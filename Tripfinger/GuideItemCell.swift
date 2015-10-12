//
//  GuideItemCell.swift
//  Tripfinger
//
//  Created by Preben Ludviksen on 08/10/15.
//  Copyright (c) 2015 Preben Ludviksen. All rights reserved.
//

import Foundation

protocol GuideItemContainerDelegate: class {
    func readMoreClicked()
}

class GuideItemCell: UITableViewCell {
    
    @IBOutlet weak var content: UITextView!
    @IBOutlet weak var contentHeight: NSLayoutConstraint!
    @IBOutlet weak var contentBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var readMoreButton: UIButton!
    weak var delegate: GuideItemContainerDelegate!
    
    
    @IBAction func readMore() {
        let fixedWidth = content.frame.size.width
        let newSize = content.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        contentHeight.constant = newSize.height;
        
        readMoreButton.hidden = true
        contentBottomMargin.constant = 0
        
        delegate.readMoreClicked()        
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        
    }
}