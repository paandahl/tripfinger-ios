import Foundation

protocol GuideItemContainerDelegate: class {
  func readMoreClicked()
  func downloadClicked()
  func updateTableSize()
}

class GuideItemCell: UITableViewCell {

  var constraintsAdded = false
  let contentImage = UIImageView()
  var contentImageHeightConstraint: NSLayoutConstraint!
  var contentImageMarginConstraint: NSLayoutConstraint!
  let content = UITextView()
  var contentHeight: CGFloat = 100
  var contentHeightConstraint: NSLayoutConstraint!
  let downloadView = UIView()
  let downloadButton = UIButton(type: .System)
  var readMoreButton: UIButton!
  var readMoreButtonHeight: Int!
  var readMoreButtonHeightConstraint: NSLayoutConstraint!
  var readMoreButtonMarginConstraint: NSLayoutConstraint!
  weak var delegate: GuideItemContainerDelegate!
  
  override required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    content.linkTextAttributes[NSForegroundColorAttributeName] = UIColor.blackColor()
    content.editable = false
    readMoreButton = UIButton(type: .System)
    readMoreButton.setTitle("Read more", forState: .Normal)
    readMoreButton.sizeToFit()
    contentView.addSubview(contentImage)
    
    downloadView.backgroundColor = UIColor.whiteColor()
    downloadView.alpha = 0.6
    downloadView.layer.cornerRadius = 10.0
    downloadView.addSubview(downloadButton)
    contentView.addSubview(content)
    contentView.addSubview(readMoreButton)
    contentView.addSubview(downloadView)

    readMoreButton.addTarget(self, action: "readMore", forControlEvents: .TouchUpInside)
    downloadButton.addTarget(self, action: "openDownloadCountry", forControlEvents: .TouchUpInside)
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  override func updateConstraints() {
    super.updateConstraints()
    if !constraintsAdded {
      var views: [String: UIView] = ["button": downloadButton]
      downloadView.addConstraints("V:|-5-[button]-5-|", forViews: views)
      downloadView.addConstraints("H:|-10-[button]-10-|", forViews: views)
      
      views = ["image": contentImage, "download": downloadView, "text": content, "readMore": readMoreButton]
      contentView.addConstraints("V:|-20-[download]", forViews: views)
      contentView.addConstraints("H:[download]-20-|", forViews: views)
      
      contentImageHeightConstraint = try! contentView.addConstraint("V:[image(225)]", forViews: views)
      contentView.addConstraints("V:|-0-[image]", forViews: views)
      contentImageMarginConstraint = try! contentView.addConstraint("V:[image]-10-[text]", forViews: views)
      contentHeightConstraint = try! contentView.addConstraint("V:[text(100)]", forViews: views)
      contentView.addConstraints("H:|-0-[image]-0-|", forViews: views)
      contentView.addConstraint(.CenterX, forView: contentImage)
      
      contentView.addConstraints("H:|-10-[text]-10-|", forViews: views)
      readMoreButtonHeight = Int(readMoreButton.frame.size.height)
      readMoreButtonHeightConstraint = try! contentView.addConstraint("V:[readMore(\(readMoreButtonHeight))]", forViews: views)
      
      contentView.addConstraints("V:[text]-10-[readMore]", forViews: views)
      readMoreButtonMarginConstraint = try! contentView.addConstraint("V:[readMore]-10-|", forViews: views)
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
    contentHeightConstraint.constant = contentHeight
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
    let fixedWidth = UIScreen.mainScreen().bounds.width - 20
    let newSize = content.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
    contentHeight = newSize.height - 20 // last paragraphs margin
    readMoreButton.hidden = true
    setNeedsUpdateConstraints()
    
    content.setContentOffset(CGPointZero, animated: false)
  }
  
  func readMore() {
    delegate.readMoreClicked()
  }
  
  func openDownloadCountry() {
    delegate.downloadClicked()
  }
  
  func setContentFromGuideItem(guideItem: GuideItem) {    
    contentImage.image = UIImage(named: "placeholder-712")
    if guideItem.images.count > 0 {
      
      if guideItem.offline {
        contentImage.contentMode = UIViewContentMode.ScaleAspectFill
        print("offline url: \(guideItem.images[0].getFileUrl())")
        contentImage.image = UIImage(data: NSData(contentsOfURL: guideItem.images[0].getFileUrl())!)
      }
      else {
        let imageUrl = guideItem.images[0].url + "-712x534"
        try! contentImage.loadImageWithUrl(imageUrl)
      }
      contentImage.hidden = false
    }
    else {
      contentImage.hidden = true
//      contentImage.removeFromSuperview()
//      contentView.addSubview(contentImage)
    }
    
    // download button
    if guideItem.category == Region.Category.COUNTRY.rawValue {
      let downloaded = DownloadService.isCountryDownloaded(guideItem.name)
      let title = downloaded ? "Downloaded" : "Download"
      downloadButton.setTitle(title, forState: .Normal)
      downloadView.hidden = false
      print("displaying downloadButton")
    } else {
      downloadView.hidden = true
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
    content.sizeToFit()
    content.scrollEnabled = false
    content.setContentOffset(CGPointZero, animated: true)
    
    setNeedsUpdateConstraints()

  }
}