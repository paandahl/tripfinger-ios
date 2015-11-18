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
    func updateTableSize()
}

class GuideItemCell: UITableViewCell {
    
    @IBOutlet var contentImage: UIImageView!
    @IBOutlet weak var content: UITextView!
    @IBOutlet weak var contentHeight: NSLayoutConstraint!
    @IBOutlet weak var contentBottomMargin: NSLayoutConstraint!
    @IBOutlet var readMoreButton: UIButton!
    weak var delegate: GuideItemContainerDelegate!
    var myConstraints = [NSLayoutConstraint]()
    
    override func awakeFromNib() {
        print("awakeFromNib")
        content.linkTextAttributes[NSForegroundColorAttributeName] = UIColor.blackColor()
        content.textContainerInset = UIEdgeInsetsMake(15, 10, 0, 10);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        print("updateContraints")
        
        contentView.removeConstraints(myConstraints)
        
        if readMoreButton.isDescendantOfView(self.contentView) {
            let const = contentView.addConstraints("V:[readMore]-10-|", forViews: ["readMore": readMoreButton])
            myConstraints.appendContentsOf(const)
        }
        else {
            let const = contentView.addConstraints("V:[content]-0-|", forViews: ["content": content])
            myConstraints.appendContentsOf(const)
        }
        
        if contentImage.isDescendantOfView(self.contentView) {
            print("Image is in the game")
            var const = contentView.addConstraints("V:|-10-[image]-10-[content]", forViews: ["image": contentImage,
                "content": content])
            myConstraints.appendContentsOf(const)
            const = contentView.addConstraints("H:|-15-[image]", forViews: ["image": contentImage])
            myConstraints.appendContentsOf(const)
        }
        else {
            let const = contentView.addConstraints("V:|-10-[content]", forViews: ["content": content])
            myConstraints.appendContentsOf(const)
        }
    }
    
    override func prepareForReuse() {
        print("prepareForReuse")
        
//        if !readMoreButton.isDescendantOfView(contentView) {
//            contentView.addSubview(readMoreButton)
//        }
//        if !contentImage.isDescendantOfView(contentView) {
//            print("Adding contentview back to tree")
//            contentView.addSubview(contentImage)
//        }
//        setNeedsUpdateConstraints()
    }
    
    func expand() {
        let fixedWidth = content.frame.size.width
        let newSize = content.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        contentHeight.constant = newSize.height - 20 // last paragraphs margin
        readMoreButton.removeFromSuperview()
        setNeedsUpdateConstraints()
        
        content.setContentOffset(CGPointZero, animated: false)
    }
        
    @IBAction func readMore() {
        delegate.readMoreClicked()
    }
    
    func setContent(guideItem: GuideItem) {
        print("setContent: \(guideItem.name)")

        if guideItem.images.count > 0 {
            print("Loading image")
            let imageUrl = guideItem.images[0].url + "-712x534"
            contentImage.loadImageWithUrl(imageUrl)
        }
        else {
            contentImage.removeFromSuperview()
            setNeedsUpdateConstraints()
        }

        
        if let description = guideItem.content {
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