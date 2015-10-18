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
    @IBOutlet var readMoreButton: UIButton!
    weak var delegate: GuideItemContainerDelegate!
    var contentSize: CGRect = CGRectZero
    
    override func awakeFromNib() {
        if !readMoreButton.isDescendantOfView(self.contentView) {
            self.contentView.addSubview(readMoreButton)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        if readMoreButton.isDescendantOfView(self.contentView) {
            self.contentView.addConstraints("V:[readMore]-10-|", forViews: ["readMore": readMoreButton])
        }
        else {
            self.contentView.addConstraints("V:[content]-10-|", forViews: ["content": content])
        }
    }
    
    func expand() {
        contentHeight.constant = contentSize.height
        readMoreButton.removeFromSuperview()
        setNeedsUpdateConstraints()
        
        content.setContentOffset(CGPointZero, animated: false)
    }
        
    @IBAction func readMore() {
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
            
            let width = content.frame.size.width
             contentSize = attributedString.boundingRectWithSize(CGSizeMake(width, 1000), options: NSStringDrawingOptions.UsesLineFragmentOrigin | NSStringDrawingOptions.UsesFontLeading, context: nil)

        }
        content.scrollEnabled = false
        content.setContentOffset(CGPointZero, animated: true)
    }
}