import Foundation

@objc protocol PlacePageInfoCellDelegate {
  func navigatedToGuide();
}

class PlacePageInfoCell: UITableViewCell {
  
  var delegate: PlacePageInfoCellDelegate?
  var entity: TripfingerEntity!
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
    
    contentView.clipsToBounds = true
    selectionStyle = .None
    
    descriptionText.editable = false
    contentView.addSubview(myImageView)
    contentView.addSubview(descriptionText)
  }

  @objc(initWithCoder:)
  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented ")
  }
  
  func setContentFromGuideItem(tripfingerEntity: TripfingerEntity) {
    if contentSet {
      return
    }
    self.entity = tripfingerEntity
    
    myImageView.contentMode = UIViewContentMode.ScaleAspectFill
    myImageView.image = UIImage(named: "placeholder-712")
    let imageHeight: Int
    if tripfingerEntity.url != "" {
      
      let alignment = UIDevice.currentDevice().orientation
      print("adding picture for portrait: \(alignment.isPortrait)")
      if tripfingerEntity.offline {
        print("offline url: \(tripfingerEntity.getFileUrl())")
        myImageView.image = UIImage(data: NSData(contentsOfURL: tripfingerEntity.getFileUrl())!)
      }
      else {
        let imageUrl = DownloadService.gcsImagesUrl + tripfingerEntity.url + "-712x534"
        try! myImageView.loadImageWithUrl(imageUrl)
      }
      imageHeight = Int(myWidth * 0.75)
    }
    else {
      imageHeight = 45
      print("No image")
    }
    
    contentView.addConstraints("H:|-0-[image]-0-|", forViews: ["image": myImageView])
    contentView.addConstraints("V:|-0-[image(\(imageHeight))]", forViews: ["image": myImageView])
    
    licenseButton.setTitle("Content license", forState: .Normal)
    licenseButton.titleLabel!.font = UIFont.systemFontOfSize(12.0)
    licenseButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
    licenseButton.sizeToFit()
    licenseButton.addTarget(self, action: #selector(navigateToLicense), forControlEvents: .TouchUpInside)
    contentView.addSubview(licenseButton)
    var views = ["description": descriptionText, "image": myImageView, "license": licenseButton]
    contentView.addConstraints("V:[license]-20-[description]", forViews: views)
    contentView.addConstraints("H:[license]-20-|", forViews: views)
    
    descriptionText.attributedText = tripfingerEntity.content.attributedString(17.0)
    descriptionText.sizeToFit()
    descriptionText.scrollEnabled = false
    descriptionText.setContentOffset(CGPointZero, animated: true)
    descriptionText.delegate = self
    
    let fixedWidth = myWidth - 10
    let newSize = descriptionText.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
    
    let contentHeight = Int(newSize.height + 1) - 10 // last paragraphs margin
    print("htmlContent width: \(fixedWidth) height: \(contentHeight)")
    views = ["description": descriptionText, "image": myImageView]
    contentView.addConstraints("V:[image]-5-[description(\(contentHeight))]", forViews: views)
    contentView.addConstraints("H:|-5-[description]-5-|", forViews: views)

    var bottomElement = descriptionText
    
    if tripfingerEntity.price != "" {
      contentView.addSubview(priceLabel)
      contentView.addSubview(priceText)
      priceLabel.text = "Price"
      priceLabel.font = UIFont.boldSystemFontOfSize(16)
      priceText.editable = false
      priceText.scrollEnabled = false
      priceText.font = UIFont.systemFontOfSize(16)
      priceText.text = tripfingerEntity.price
      let priceSize = priceText.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
      views = ["description": descriptionText, "priceLabel": priceLabel, "priceText": priceText]
      contentView.addConstraints("V:[description]-0-[priceLabel]-10-[priceText(\(priceSize.height))]", forViews: views)
      contentView.addConstraints("H:|-9-[priceLabel]-5-|", forViews: views)
      contentView.addConstraints("H:|-5-[priceText]-5-|", forViews: views)
      bottomElement = priceText
    }
    
    if tripfingerEntity.directions != "" {
      contentView.addSubview(directionsLabel)
      contentView.addSubview(directionsText)
      directionsLabel.text = "Directions"
      directionsLabel.font = UIFont.boldSystemFontOfSize(16)
      directionsText.editable = false
      directionsText.scrollEnabled = false
      directionsText.attributedText = tripfingerEntity.directions.attributedString(16.0)
      directionsText.sizeToFit()
      directionsText.delegate = self
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
    let licenseController = LicenseController(entity: entity)
    licenseController.edgesForExtendedLayout = .None // offset from navigation bar
    TripfingerAppDelegate.navigationController.pushViewController(licenseController, animated: true)
  }
}

extension PlacePageInfoCell: UITextViewDelegate {
  
  func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
    if let tripfingerUrl = TripfingerUrl(url: URL) {
      let finishedHandler = {
        self.hideHuds()
        TripfingerAppDelegate.navigationController.navigationBarHidden = false
        if let delegate = self.delegate {
          delegate.navigatedToGuide()
        }
      }

      // there are four outcomes for a link navigation from the placepage
      //
      // 1. we're in DetailsView on guide and can just push the new viewcontroller to the hierarchy
      // 2. we're in the MapView and
      //    a.I. we're going to an offline listing, and can select it directly on the map
      //    a.II. we're going to a non-offline listing, and need to jump to a new guide hierarchy
      //    b. we're going to a region and need to jump to a new guide hierarchy

      showLoadingHud()
      let nav = TripfingerAppDelegate.navigationController
      if nav.viewControllers.last! is DetailController {
        nav.navigateToTripfingerUrl(tripfingerUrl, failure: showErrorHud, finishedHandler: finishedHandler)
      } else if let listingSlug = tripfingerUrl.listingSlug() {
        if let offlineListing = DatabaseService.getListingWithSlug(listingSlug) {
          self.hideHuds()
          let entity = TripfingerEntity(listing: offlineListing)
          MapsAppDelegateWrapper.selectListing(entity)
        } else {
          nav.jumpToListingWithSlug(listingSlug, failure: showErrorHud, finishedHandler: finishedHandler)
        }
      } else {
        nav.jumpToRegionWithSlug(tripfingerUrl.regionSlug(), failure: showErrorHud, finishedHandler: finishedHandler)
      }
      return false
    }    
    return true
  }
}