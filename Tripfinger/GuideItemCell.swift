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

  var constraintsAdded = false
  var contentImage: UIImageView!
  var contentImageHeightConstraint: NSLayoutConstraint!
  var contentImageMarginConstraint: NSLayoutConstraint!
  var content: UITextView!
  var contentHeightConstraint: NSLayoutConstraint!
  var readMoreButton: UIButton!
  var readMoreButtonHeight: Int!
  var readMoreButtonHeightConstraint: NSLayoutConstraint!
  var readMoreButtonMarginConstraint: NSLayoutConstraint!
  weak var delegate: GuideItemContainerDelegate!
  
  override func awakeFromNib() {
    content.linkTextAttributes[NSForegroundColorAttributeName] = UIColor.blackColor()
    content.textContainerInset = UIEdgeInsetsMake(15, 10, 0, 10);
  }
  
  override required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    contentImage = UIImageView()
    contentView.addSubview(contentImage)
    content = UITextView()
    content.editable = false
    contentView.addSubview(content)
    readMoreButton = UIButton(type: .System)
    readMoreButton.setTitle("Read more", forState: .Normal)
    readMoreButton.sizeToFit()
    readMoreButton.addTarget(self, action: "readMore:", forControlEvents: .TouchUpInside)

    contentView.addSubview(readMoreButton)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func updateConstraints() {
    super.updateConstraints()
    
    if (!constraintsAdded) {
      let views = ["image": contentImage, "text": content, "readMore": readMoreButton]
      contentImageHeightConstraint = contentView.addConstraints("V:[image(225)]", forViews: views)[0]
      contentView.addConstraints("V:|-10-[image]", forViews: views)
      contentImageMarginConstraint = contentView.addConstraints("V:[image]-10-[text]", forViews: views)[0]
      contentHeightConstraint = contentView.addConstraints("V:[text(100)]", forViews: views)[0]
      contentView.addConstraints("H:[image(300)]", forViews: views)
      contentView.addConstraint(.CenterX, forView: contentImage)
      
      contentView.addConstraints("H:|-10-[text]-10-|", forViews: views)
      readMoreButtonHeight = Int(readMoreButton.frame.size.height)
      readMoreButtonHeightConstraint = contentView.addConstraints("V:[readMore(\(readMoreButtonHeight))]", forViews: views)[0]
      
      contentView.addConstraints("V:[text]-10-[readMore]", forViews: views)
      readMoreButtonMarginConstraint = contentView.addConstraints("V:[readMore]-10-|", forViews: views)[0]
      contentView.addConstraints("H:|-14-[readMore]", forViews: views)
      constraintsAdded = true
    }
    
    if contentImage.hidden {
      contentImageHeightConstraint.constant = 0
      contentImageMarginConstraint.constant = 0
    }
    else {
      contentImageHeightConstraint.constant = 225
      contentImageMarginConstraint.constant = 10
    }
    if readMoreButton.hidden {
      readMoreButtonHeightConstraint.constant = 0
      readMoreButtonMarginConstraint.constant = 0
    }
    else {
      readMoreButtonHeightConstraint.constant = CGFloat(readMoreButtonHeight)
      readMoreButtonMarginConstraint.constant = 10
    }
  }
  
  override func prepareForReuse() {
    if (!contentImage.isDescendantOfView(contentView)) {
      contentView.addSubview(contentImage)
    }
    if (!readMoreButton.isDescendantOfView(contentView)) {
      contentView.addSubview(readMoreButton)
    }
  }
  
  func expand() {
    let fixedWidth = content.frame.size.width
    let newSize = content.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
    contentHeightConstraint.constant = newSize.height - 20 // last paragraphs margin
    readMoreButton.hidden = true
    setNeedsUpdateConstraints()
    
    content.setContentOffset(CGPointZero, animated: false)
  }
  
  func readMore(sender: UIButton) {
    delegate.readMoreClicked()
  }
  
  func setContentFromGuideItem(guideItem: GuideItem) {    
    contentImage.image = UIImage(named: "placeholder-712")
    if guideItem.images.count > 0 {
      let imageUrl = guideItem.images[0].url + "-712x534"
      print("Loading image with url: " + imageUrl)
      try! contentImage.loadImageWithUrl(imageUrl)
      contentImage.hidden = false
    }
    else {
      contentImage.hidden = true
//      contentImage.removeFromSuperview()
//      contentView.addSubview(contentImage)
//      setNeedsUpdateConstraints()
    }
    

    var description = ""
    if let content = guideItem.content {
      description = content
      
    }
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
    
    content.scrollEnabled = false
    content.setContentOffset(CGPointZero, animated: true)
  }
}