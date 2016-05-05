import Foundation

class PlacePageInfoCell: UITableViewCell {
  
  var contentSet = false
  let myImageView = UIImageView()
  let licenseButton = UIButton()
  let descriptionText = UITextView()
  let priceLabel = UILabel()
  let priceText = UITextView()
  let directionsLabel = UILabel()
  let directionsText = UITextView()
  let myWidth: CGFloat

  init(width: CGFloat) {
    self.myWidth = width
    super.init(style: .Default, reuseIdentifier: nil)
    
    selectionStyle = .None
    
    contentView.addSubview(myImageView)
    contentView.addSubview(descriptionText)
    let imageHeight = width * 0.75
    contentView.addConstraints("H:|-0-[image]-0-|", forViews: ["image": myImageView])
    contentView.addConstraints("V:|-0-[image(\(imageHeight))]", forViews: ["image": myImageView])
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented ")
  }
  
  func setContentFromGuideItem(tripfingerEntity: TripfingerEntity) {
    if contentSet {
      return
    }
    
    myImageView.contentMode = UIViewContentMode.ScaleAspectFill
    myImageView.image = UIImage(named: "placeholder-712")
    if tripfingerEntity.url != nil {
      
      let alignment = UIDevice.currentDevice().orientation
      print("adding picture for portrait: \(alignment.isPortrait)")
      if tripfingerEntity.offline! {
        print("offline url: \(tripfingerEntity.getFileUrl())")
        myImageView.image = UIImage(data: NSData(contentsOfURL: tripfingerEntity.getFileUrl())!)
      }
      else {
        let imageUrl = DownloadService.gcsImagesUrl + tripfingerEntity.url + "-712x534"
        try! myImageView.loadImageWithUrl(imageUrl)
      }
    }
    else {
      print("No image")
      let blankImage = UIImage(withColor: UIColor.lightGrayColor(), size: CGSizeMake(200, 200))
      myImageView.image = textToImage("This is a draft without image.", inImage: blankImage, atPoint: CGPointMake(50, 100))
    }
    
    licenseButton.setTitle("Content license", forState: .Normal)
    licenseButton.titleLabel!.font = UIFont.systemFontOfSize(12.0)
    licenseButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
    licenseButton.sizeToFit()
    licenseButton.addTarget(self, action: "navigateToLicense", forControlEvents: .TouchUpInside)
    contentView.addSubview(licenseButton)
    var views = ["description": descriptionText, "image": myImageView, "license": licenseButton]
    contentView.addConstraints("V:[license]-20-[description]", forViews: views)
    contentView.addConstraints("H:[license]-20-|", forViews: views)
    
    let encodedData = tripfingerEntity.content.dataUsingEncoding(NSUTF8StringEncoding)!
    let style = NSMutableParagraphStyle()
    style.lineSpacing = 5
    style.paragraphSpacing = 10
    let options : [String: AnyObject] = [
      NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
      NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding,
    ]
    let attributes : [String: AnyObject] = [
      NSFontAttributeName: UIFont.systemFontOfSize(17.0),
      NSForegroundColorAttributeName: UIColor.blackColor(),
      NSParagraphStyleAttributeName: style
    ]
    let attributedString = try! NSMutableAttributedString(data: encodedData, options: options, documentAttributes: nil)
    attributedString.setAttributes(attributes, range: NSMakeRange(0, attributedString.length))


    print(tripfingerEntity.content)

    descriptionText.attributedText = attributedString
    descriptionText.sizeToFit()
    descriptionText.scrollEnabled = false
    descriptionText.setContentOffset(CGPointZero, animated: true)
    
    let fixedWidth = myWidth - 10
    let newSize = descriptionText.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
    
    let contentHeight = newSize.height - 10 // last paragraphs margin
    print("htmlContent width: \(fixedWidth) height: \(contentHeight)")
    views = ["description": descriptionText, "image": myImageView]
    contentView.addConstraints("V:[image]-5-[description(\(contentHeight))]", forViews: views)
    contentView.addConstraints("H:|-5-[description]-5-|", forViews: views)

    var bottomElement = descriptionText
    
    if let price = tripfingerEntity.price {
      contentView.addSubview(priceLabel)
      contentView.addSubview(priceText)
      priceLabel.text = "Price"
      priceLabel.font = UIFont.boldSystemFontOfSize(16)
      priceText.scrollEnabled = false
      priceText.font = UIFont.systemFontOfSize(16)
      priceText.text = price
      priceText.sizeToFit()
      views = ["description": descriptionText, "priceLabel": priceLabel, "priceText": priceText]
      contentView.addConstraints("V:[description]-0-[priceLabel]-10-[priceText]", forViews: views)
      contentView.addConstraints("H:|-9-[priceLabel]-5-|", forViews: views)
      contentView.addConstraints("H:|-5-[priceText]-5-|", forViews: views)
      bottomElement = priceText
    }
    
    if let directions = tripfingerEntity.directions {
      contentView.addSubview(directionsLabel)
      contentView.addSubview(directionsText)
      directionsLabel.text = "Directions"
      directionsLabel.font = UIFont.boldSystemFontOfSize(16)
      directionsText.scrollEnabled = false
      directionsText.font = UIFont.systemFontOfSize(16)
      directionsText.text = directions
      let dirSize = directionsText.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))

      print("directionsText height: \(directionsText.height)")
      print("dirSize height: \(dirSize.height)")
      views = ["bottom": bottomElement, "dirLabel": directionsLabel, "dirText": directionsText]
      contentView.addConstraints("V:[bottom]-20-[dirLabel]-10-[dirText(\(dirSize.height))]", forViews: views)
      contentView.addConstraints("H:|-9-[dirLabel]-5-|", forViews: views)
      contentView.addConstraints("H:|-5-[dirText]-5-|", forViews: views)
      bottomElement = directionsText
    }
    
    views = ["bottom": bottomElement]
    contentView.addConstraints("V:[bottom]-5-|", forViews: views)

    contentSet = true
  }

  func textToImage(drawText: NSString, inImage: UIImage, atPoint:CGPoint)->UIImage{
    let textColor: UIColor = UIColor.blackColor()
    let textFont: UIFont = UIFont(name: "Helvetica Bold", size: 20)!
    
    UIGraphicsBeginImageContext(inImage.size)
    
    let textFontAttributes = [
      NSFontAttributeName: textFont,
      NSForegroundColorAttributeName: textColor,
    ]
    
    inImage.drawInRect(CGRectMake(0, 0, inImage.size.width, inImage.size.height))
    let rect: CGRect = CGRectMake(atPoint.x, atPoint.y, inImage.size.width, inImage.size.height)
    drawText.drawInRect(rect, withAttributes: textFontAttributes)
    let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    
    return newImage
  }

//  func heartClick() {
//    if let notes = listing.listing.notes where notes.likedState == GuideListingNotes.LikedState.LIKED {
//      print("unselected heart")
//      DatabaseService.saveLike(GuideListingNotes.LikedState.SWIPED_LEFT, listing: listing)
//    } else {
//      DatabaseService.saveLike(GuideListingNotes.LikedState.LIKED, listing: listing)
//    }
//    setHeartTint()
//  }
  
  func navigateToLicense() {
    TripfingerAppDelegate.navigateToLicense()
  }
}