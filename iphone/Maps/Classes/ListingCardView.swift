import UIKit
import MDCSwipeToChoose

protocol ListingCardContainer: class {
  func showDetail(attraction: Listing)
}

class ListingCardView: MDCSwipeToChooseView {
  
  let ChoosePersonViewImageLabelWidth:CGFloat = 42.0;
  var listing: Listing!
  var informationView: UIView!
  var nameLabel: UILabel!
  var carmeraImageLabelView: ImagelabelView!
  var interestsImageLabelView: ImagelabelView!
  var friendsImageLabelView: ImagelabelView!
  var delegate: ListingCardContainer!
  
  init(frame: CGRect, listing: Listing, delegate: ListingCardContainer, options: MDCSwipeToChooseViewOptions) {
    
    super.init(frame: frame, options: options)
    self.listing = listing
    self.delegate = delegate
    
    if listing.listing.item.offline {
      imageView.contentMode = UIViewContentMode.ScaleAspectFill
      print("loading attraction image \(listing.item().images[0].getFileUrl())")
      imageView.image = UIImage(data: NSData(contentsOfURL: listing.item().images[0].getFileUrl())!)
    } else {
      imageView.contentMode = UIViewContentMode.ScaleAspectFill
      imageView.image = UIImage(withColor: UIColor.whiteColor())
      let imageUrl = DownloadService.gcsImagesUrl + listing.listing.item.images[0].url + "-600x800"
      try! imageView.loadImageWithUrl(imageUrl)
    }
    
    imageView.tag = 2000
    
    constructInformationView()
    
    let singleTap = UITapGestureRecognizer(target: self, action: "imageClick:")
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    imageView.addGestureRecognizer(singleTap)
    imageView.userInteractionEnabled = true
    
    informationView.alpha = 0.6
    let views = ["image": imageView!, "info": informationView!]
//    addConstraints("V:|-0-[image(400)]-0-|", forViews: views)
    addConstraints("V:[info(80)]|", forViews: views)
    addConstraint(NSLayoutConstraint(item: informationView, attribute: .Bottom, relatedBy: .Equal, toItem: imageView, attribute: .Bottom, multiplier: 1.0, constant: 0))
    addConstraints("H:|-0-[info]-0-|", forViews: views)
    addConstraints("H:|-0-[image]-0-|", forViews: views)
    addConstraints("V:|-0-[image]-0-|", forViews: views)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func imageClick(sender: UIImageView) {
    delegate.showDetail(listing)
  }
  
  func constructInformationView() -> Void{
    informationView = UIView()
    informationView.backgroundColor = UIColor.whiteColor()
    addSubview(informationView)
    constructNameLabel()
    informationView.tag = 3000
    let views: [String: UIView] = ["name": nameLabel]
    informationView.addConstraints("V:|-20-[name(60)]-0-|", forViews: views)
    informationView.addConstraints("H:|-12-[name]-0-|", forViews: views)
  }
  
  func constructNameLabel() -> Void{
    nameLabel = UILabel()
    nameLabel.text = listing.listing.item.name!
    nameLabel.numberOfLines = 0
    nameLabel.lineBreakMode = .ByWordWrapping
    informationView .addSubview(nameLabel)
    
  }
}
