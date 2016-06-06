import Foundation

class AnnotationCalloutView : UIView {
  
  var titleLabel: UILabel!
  var detailButton: UIButton!

  let pois: [SimplePOI]
  var index = 0
  var detailAction: ((SimplePOI) -> ())!
  
  var currentPoi: SimplePOI {
    get { return pois[index] }
  }
  
  init(pois: [SimplePOI], detailAction: (SimplePOI) -> ()) {
    self.pois = pois
    super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    self.detailAction = detailAction
    
    backgroundColor = UIColor.whiteColor()
    alpha = 0.7
    layer.cornerRadius = 5
    layer.masksToBounds = true
    
    titleLabel = UILabel()
    addSubview(titleLabel)
    
    detailButton = UIButton(type: .System)
    detailButton.setTitle("Details", forState: .Normal)
    detailButton.addTarget(self, action: #selector(detailButtonClicked), forControlEvents: .TouchUpInside)
    detailButton.sizeToFit()
    addSubview(detailButton)
    
    let views = ["title": titleLabel, "detail": detailButton]
    addConstraints("H:|-10-[title]-[detail(60)]-10-|", forViews: views)
    addConstraints("V:|-5-[title]-5-|", forViews: views)
    addConstraints("V:|-5-[detail]-5-|", forViews: views)
    
    let leftSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
    leftSwipeRecognizer.delegate = self
    leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirection.Left
    addGestureRecognizer(leftSwipeRecognizer)
    let rightSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
    rightSwipeRecognizer.delegate = self
    addGestureRecognizer(rightSwipeRecognizer)

    updateView()
  }
  
  func updateView() {
    var titleText = currentPoi.name
    if pois.count > 1 {
      titleText = "\(index+1)/\(pois.count) \(titleText)"
    }
    titleLabel.text = titleText
    titleLabel.sizeToFit()

    detailButton.hidden = (currentPoi.listingId == nil || currentPoi.listingId == "simple")
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  func detailButtonClicked() {
    detailAction(currentPoi)
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
}

extension AnnotationCalloutView: UIGestureRecognizerDelegate {
  func handleSwipe(recognizer: UISwipeGestureRecognizer) {
    if recognizer.direction == UISwipeGestureRecognizerDirection.Left {
      if index > 0 {
        index -= 1
        updateView()
      }
    } else if recognizer.direction == UISwipeGestureRecognizerDirection.Right {
      if index < pois.count - 1 {
        index += 1
        updateView()
      }
    }
  }
}