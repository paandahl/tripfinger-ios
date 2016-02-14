import Foundation

protocol ListingCellContainer: class {
  func showDetail(attraction: Attraction)
}

class ListingCell: UITableViewCell {
  
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var mainImage: UIImageView!
  @IBOutlet weak var heartImage: UIImageView!
  var attraction: Attraction!
  var delegate: ListingCellContainer!
  
  override func awakeFromNib() {
    let singleTap = UITapGestureRecognizer(target: self, action: "imageClick:")
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    mainImage.addGestureRecognizer(singleTap)
    mainImage.userInteractionEnabled = true
    heartImage.image = heartImage.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
  }
  
  func setContent(attraction: Attraction) {
    name.text = attraction.listing.item.name
    mainImage.image = UIImage(named: "Placeholder")
    if attraction.swipeState == Attraction.SwipeState.SWIPED_RIGHT {
      heartImage.tintColor = UIColor.redColor()
    }
    else {
      heartImage.tintColor = UIColor.darkGrayColor()
    }
    
    if attraction.item().offline {
      mainImage.contentMode = UIViewContentMode.ScaleAspectFill
      mainImage.image = UIImage(data: NSData(contentsOfURL: attraction.item().images[0].getFileUrl())!)
    }
    else {
      let imageUrl = attraction.item().images[0].url + "-712x534"
      try! mainImage.loadImageWithUrl(imageUrl)
    }
    
    self.attraction = attraction
  }
  
  func imageClick(sender: UIImageView) {
    delegate.showDetail(attraction)
  }
}