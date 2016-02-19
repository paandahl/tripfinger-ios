import Foundation

class DetailController: UIViewController {
  
  var scrollView = UIScrollView()
  var mainImage = UIImageView()
  var name = UILabel()
  var descriptionText = UITextView()
  var priceLabel = UILabel()
  var priceText = UITextView()
  var openingHoursLabel = UILabel()
  var openingHoursText = UITextView()
  var directionsLabel = UILabel()
  var directionsText = UITextView()
  
  var attraction: Attraction!
  
  override func viewDidLoad() {
    view.addSubview(scrollView)
    scrollView.addSubview(name)
    scrollView.addSubview(mainImage)
    scrollView.addSubview(descriptionText)

    scrollView.backgroundColor = UIColor.whiteColor()

    name.font = UIFont.boldSystemFontOfSize(16)
    name.text = attraction.listing.item.name

    descriptionText.scrollEnabled = false
    let encodedData = attraction.item().content!.dataUsingEncoding(NSUTF8StringEncoding)!
    let options : [String: AnyObject] = [
      NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
      NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding,
    ]
    let attributedString = try! NSMutableAttributedString(data: encodedData, options: options, documentAttributes: nil)
    attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(16.0), range: NSMakeRange(0, attributedString.length))
    let style = NSMutableParagraphStyle()
    style.lineSpacing = 5
    style.paragraphSpacing = 20
    attributedString.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, attributedString.length))
    descriptionText.attributedText = attributedString
    
    var views = ["scroll": scrollView, "name": name, "image": mainImage, "description": descriptionText]
    view.addConstraints("V:|-0-[scroll]-0-|", forViews: views)
    view.addConstraints("H:|-0-[scroll]-0-|", forViews: views)
    let widthConstraint = NSLayoutConstraint(item: mainImage, attribute: .Width, relatedBy: .Equal, toItem: scrollView, attribute: .Width, multiplier: 1.0, constant: 0)
    view.addConstraint(widthConstraint)
    
    scrollView.addConstraints("V:|-0-[image(283)]-20-[name]-20-[description]", forViews: views)
    scrollView.addConstraints("H:|-0-[image]-0-|", forViews: views)
    scrollView.addConstraints("H:|-20-[name]", forViews: views)
    scrollView.addConstraints("H:|-20-[description]-20-|", forViews: views)
    var bottomElement = descriptionText
    
    if let price = attraction.price {
      scrollView.addSubview(priceLabel)
      scrollView.addSubview(priceText)
      priceLabel.text = "Price"
      priceLabel.font = UIFont.boldSystemFontOfSize(16)
      priceText.scrollEnabled = false
      priceText.font = UIFont.systemFontOfSize(16)
      priceText.text = price
      views = ["description": descriptionText, "priceLabel": priceLabel, "priceText": priceText]
      scrollView.addConstraints("V:[description]-20-[priceLabel]-20-[priceText]", forViews: views)
      scrollView.addConstraints("H:|-20-[priceLabel]-20-|", forViews: views)
      scrollView.addConstraints("H:|-20-[priceText]-20-|", forViews: views)
      bottomElement = priceText
    }
    
    if let openingHours = attraction.openingHours {
      scrollView.addSubview(openingHoursLabel)
      scrollView.addSubview(openingHoursText)
      openingHoursLabel.text = "Opening hours"
      openingHoursLabel.font = UIFont.boldSystemFontOfSize(16)
      openingHoursText.scrollEnabled = false
      openingHoursText.font = UIFont.systemFontOfSize(16)
      openingHoursText.text = openingHours
      views = ["bottom": bottomElement, "hoursLabel": openingHoursLabel, "hoursText": openingHoursText]
      scrollView.addConstraints("V:[bottom]-20-[hoursLabel]-20-[hoursText]", forViews: views)
      scrollView.addConstraints("H:|-20-[hoursLabel]-20-|", forViews: views)
      scrollView.addConstraints("H:|-20-[hoursText]-20-|", forViews: views)
      bottomElement = openingHoursText
    }

    if let directions = attraction.directions {
      scrollView.addSubview(directionsLabel)
      scrollView.addSubview(directionsText)
      directionsLabel.text = "Directions"
      directionsLabel.font = UIFont.boldSystemFontOfSize(16)
      directionsText.scrollEnabled = false
      directionsText.font = UIFont.systemFontOfSize(16)
      directionsText.text = directions
      views = ["bottom": bottomElement, "dirLabel": directionsLabel, "dirText": directionsText]
      scrollView.addConstraints("V:[bottom]-20-[dirLabel]-20-[dirText]", forViews: views)
      scrollView.addConstraints("H:|-20-[dirLabel]-20-|", forViews: views)
      scrollView.addConstraints("H:|-20-[dirText]-20-|", forViews: views)
      bottomElement = directionsText
    }

    let bottomConstraint = NSLayoutConstraint(item: bottomElement, attribute: .Bottom, relatedBy: .Equal, toItem: scrollView, attribute: .Bottom, multiplier: 1.0, constant: -20)
    view.addConstraint(bottomConstraint)

    mainImage.contentMode = UIViewContentMode.ScaleAspectFit
    if attraction.item().offline {
      print("fetching image from \(attraction.item().images[0].getFileUrl())")
      mainImage.image = UIImage(data: NSData(contentsOfURL: attraction.item().images[0].getFileUrl())!)
    }
    else {
      if attraction.item().images.count > 0 {
        let imageUrl = attraction.item().images[0].url + "-712x534"
        mainImage.image = UIImage(named: "Placeholder")
        try! mainImage.loadImageWithUrl(imageUrl)
      }
      else {
        print("No image")
        let blankImage = UIImage(color: UIColor.lightGrayColor(), size: CGSizeMake(200, 200))
        mainImage.image = textToImage("This is a draft without image.", inImage: blankImage, atPoint: CGPointMake(50, 100))
      }
    }
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
}