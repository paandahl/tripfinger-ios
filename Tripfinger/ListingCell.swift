import Foundation

protocol ListingCellContainer: class {
  func showDetail(attraction: Attraction)
}

class ListingCell: UITableViewCell {
  
  let mainImage = UIImageView()
  let heartImage = UIImageView()
  let descriptionView = UIView()
  let name = UILabel()
  var attraction: Attraction!
  var delegate: ListingCellContainer!
  var hasSetupConstraints = false
  var heightConstraint: NSLayoutConstraint!
  var height: CGFloat!
  
  override func updateConstraints() {
    super.updateConstraints()
    if !hasSetupConstraints {
      descriptionView.addSubview(name)
      
      var views: [String: UIView] = ["name": name]
      descriptionView.addConstraints("V:|-5-[name]-5-|", forViews: views)
      descriptionView.addConstraints("H:|-5-[name]-5-|", forViews: views)
      descriptionView.backgroundColor = UIColor.whiteColor()
      descriptionView.alpha = 0.7
      descriptionView.userInteractionEnabled = false
      
      contentView.addSubview(mainImage)
      contentView.addSubview(descriptionView)
      contentView.addSubview(heartImage)
      contentView.clipsToBounds = true
      
      views = ["desc": descriptionView, "mainImage": mainImage, "heart": heartImage]
      heightConstraint = try! contentView.addConstraint("V:[mainImage(267)]", forViews: views)
      contentView.addConstraints("V:|-0-[mainImage]-0-|", forViews: views)
      contentView.addConstraints("V:|-20-[heart]", forViews: views)
      contentView.addConstraints("V:[desc(40)]-20-|", forViews: views)
      contentView.addConstraints("H:|-0-[mainImage]-0-|", forViews: views)
      contentView.addConstraints("H:[heart]-20-|", forViews: views)
      contentView.addConstraints("H:|-20-[desc(300)]", forViews: views)
      
      let imageClick = UITapGestureRecognizer(target: self, action: "imageClick:")
      imageClick.numberOfTapsRequired = 1;
      imageClick.numberOfTouchesRequired = 1;
      mainImage.addGestureRecognizer(imageClick)
      mainImage.userInteractionEnabled = true

      heartImage.image = UIImage(named: "heart-24")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
      let heartClick = UITapGestureRecognizer(target: self, action: "heartClick")
      heartClick.numberOfTapsRequired = 1;
      heartClick.numberOfTouchesRequired = 1;
      heartImage.addGestureRecognizer(heartClick)
      heartImage.userInteractionEnabled = true
      
      hasSetupConstraints = true
    }
    heightConstraint.constant = height
  }
  
  func setContent(attraction: Attraction) {
    print("setContent for \(attraction.item().name)")
    name.text = attraction.listing.item.name
    mainImage.image = UIImage(named: "Placeholder")
    if let notes = attraction.listing.notes where notes.likedState == GuideListingNotes.LikedState.LIKED {
      heartImage.tintColor = UIColor.redColor()
      height = 130
    }
    else {
      heartImage.tintColor = UIColor.darkGrayColor()
      height = 267
    }
    
    mainImage.clipsToBounds = true
    mainImage.contentMode = UIViewContentMode.ScaleAspectFill
    if attraction.item().offline {
      mainImage.image = UIImage(data: NSData(contentsOfURL: attraction.item().images[0].getFileUrl())!)
    }
    else {
      let imageUrl = attraction.item().images[0].url + "-712x534"
      try! mainImage.loadImageWithUrl(imageUrl)
    }
    
    self.attraction = attraction
    setNeedsUpdateConstraints()
  }
  
  func imageClick(sender: UIImageView) {
    delegate.showDetail(attraction)
  }
  
  func heartClick() {
    if let notes = attraction.listing.notes where notes.likedState == GuideListingNotes.LikedState.LIKED {
      DatabaseService.saveLike(GuideListingNotes.LikedState.SWIPED_LEFT, attraction: attraction)
    } else {
      DatabaseService.saveLike(GuideListingNotes.LikedState.LIKED, attraction: attraction)
    }
    setContent(attraction)
  }
}