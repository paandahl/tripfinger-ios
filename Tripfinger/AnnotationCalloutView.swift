import Foundation

class AnnotationCalloutView : UIView {
  
  var titleLabel: UILabel!
  var detailButton: UIButton!

  var poi: SearchResult!
  var detailAction: (() -> ())!
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  init(poi: SearchResult, detailAction: () -> ()) {
    super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    self.poi = poi
    self.detailAction = detailAction
    
    backgroundColor = UIColor.whiteColor()
    alpha = 0.7
    layer.cornerRadius = 5
    layer.masksToBounds = true
    
    titleLabel = UILabel()
    titleLabel.text = poi.name
    titleLabel.sizeToFit()
    addSubview(titleLabel)
    
    detailButton = UIButton(type: .System)
    detailButton.setTitle("Details", forState: .Normal)
    detailButton.addTarget(self, action: "detailButtonClicked", forControlEvents: .TouchUpInside)
    detailButton.sizeToFit()
    detailButton.hidden = (poi.listingId == "simple")
    addSubview(detailButton)
    
    let views = ["title": titleLabel, "detail": detailButton]
    addConstraints("H:|-10-[title]-[detail]-10-|", forViews: views)
    addConstraints("V:|-5-[title]-5-|", forViews: views)
    addConstraints("V:|-5-[detail]-5-|", forViews: views)
  }

  func detailButtonClicked() {
    detailAction()
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
  }
}