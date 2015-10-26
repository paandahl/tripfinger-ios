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
    
    override func awakeFromNib() {
        content.linkTextAttributes[NSForegroundColorAttributeName] = UIColor.blackColor()
        content.textContainerInset = UIEdgeInsetsMake(15, 10, 0, 10);
        if !readMoreButton.isDescendantOfView(self.contentView) {
            self.contentView.addSubview(readMoreButton)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        if readMoreButton.isDescendantOfView(self.contentView) {
            self.contentView.addConstraints("V:[readMore]-10-|", forViews: ["readMore": readMoreButton])
        }
        else {
            self.contentView.addConstraints("V:[content]-0-|", forViews: ["content": content])
        }
    }
    
    func expand() {
        let fixedWidth = content.frame.size.width
        let newSize = content.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        contentHeight.constant = newSize.height - 20 // last paragraphs margin
//        contentHeight.constant = contentSize.height
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
            let attributedString = try! NSMutableAttributedString(data: encodedData, options: options, documentAttributes: nil)
            attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(17.0), range: NSMakeRange(0, attributedString.length))
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 5
            style.paragraphSpacing = 20
            attributedString.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, attributedString.length))
            content.attributedText = attributedString
        }
        content.scrollEnabled = false
        content.setContentOffset(CGPointZero, animated: true)
    }
}