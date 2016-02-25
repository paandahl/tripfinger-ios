import UIKit
import MDCSwipeToChoose

protocol AttractionCardContainer: class {
  func showDetail(attraction: Attraction)
}

class ChooseAttractionView: MDCSwipeToChooseView {
  
  let ChoosePersonViewImageLabelWidth:CGFloat = 42.0;
  var attraction: Attraction!
  var informationView: UIView!
  var nameLabel: UILabel!
  var carmeraImageLabelView: ImagelabelView!
  var interestsImageLabelView: ImagelabelView!
  var friendsImageLabelView: ImagelabelView!
  var delegate: AttractionCardContainer!
  
  init(frame: CGRect, attraction: Attraction, delegate: AttractionCardContainer, options: MDCSwipeToChooseViewOptions) {
    
    super.init(frame: frame, options: options)
    self.attraction = attraction
    self.delegate = delegate
    
    if attraction.listing.item.offline {
      imageView.contentMode = UIViewContentMode.ScaleAspectFill
      print("loading attraction image \(attraction.item().images[0].getFileUrl())")
      imageView.image = UIImage(data: NSData(contentsOfURL: attraction.item().images[0].getFileUrl())!)
    }
    else {
      imageView.image = UIImage(color: UIColor.whiteColor())
      let imageUrl = attraction.listing.item.images[0].url + "-600x800"
      try! imageView.loadImageWithUrl(imageUrl)
    }
    
    imageView.tag = 2000
    
    constructInformationView()
    
    let singleTap = UITapGestureRecognizer(target: self, action: "imageClick:")
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    imageView.addGestureRecognizer(singleTap)
    imageView.userInteractionEnabled = true
    
    let views = ["image": imageView!, "info": informationView!]
    addConstraints("V:|-0-[image(400)]-0-[info(80)]-0-|", forViews: views)
    addConstraints("H:|-0-[info]-0-|", forViews: views)
    addConstraints("H:|-0-[image]-0-|", forViews: views)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func imageClick(sender: UIImageView) {
    delegate.showDetail(attraction)
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
    nameLabel.text = attraction.listing.item.name!
    nameLabel.numberOfLines = 0
    nameLabel.lineBreakMode = .ByWordWrapping
    informationView .addSubview(nameLabel)
    
  }
}
