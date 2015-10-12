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
    
    func expand() {
        let fixedWidth = content.frame.size.width
        let newSize = content.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        contentHeight.constant = newSize.height;
        
        readMoreButton.hidden = true
        contentBottomMargin.constant = 0
        content.setContentOffset(CGPointZero, animated: false)
    }
        
    @IBAction func readMore() {
        expand()
        delegate.readMoreClicked()        
    }
    
    func setContent(guideItem: GuideItem) {
        if let description = guideItem.description {
            let encodedData = description.dataUsingEncoding(NSUTF8StringEncoding)!
            let options : [String: AnyObject] = [
                NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding,
            ]
            let attributedString = NSMutableAttributedString(data: encodedData, options: options, documentAttributes: nil, error: nil)!
            attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(18.0), range: NSMakeRange(0, attributedString.length))
            let decodedString = attributedString.string
            content.attributedText = attributedString
        }
        content.scrollEnabled = false
        content.setContentOffset(CGPointZero, animated: true)
        readMoreButton.hidden = false
    }
}