import Foundation

class DetailController: UIViewController {
  
  @IBOutlet weak var mainImage: UIImageView!
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var descriptionText: UITextView!
  
  var attraction: Attraction!
  
  override func viewDidLoad() {
    
    name.text = attraction.listing.item.name
    descriptionText.text = attraction.listing.item.content
    
    if attraction.item().offline {
      mainImage.contentMode = UIViewContentMode.ScaleAspectFill
      print("fetching image from \(attraction.item().images[0].getFileUrl())")
      mainImage.image = UIImage(data: NSData(contentsOfURL: attraction.item().images[0].getFileUrl())!)
    }
    else {
      if attraction.item().images.count > 0 {
        print("Loading image")
        mainImage.image = UIImage(named: "Placeholder")
        try! mainImage.loadImageWithUrl(attraction.item().images[0].url)
      }
      else {
        print("No image")
        let blankImage = UIImage(color: UIColor.lightGrayColor(), size: CGSizeMake(200, 200))
        mainImage.image = textToImage("This is a draft without image.", inImage: blankImage, atPoint: CGPointMake(50, 100))
      }
    }
  }
  
  func textToImage(drawText: NSString, inImage: UIImage, atPoint:CGPoint)->UIImage{
    
    // Setup the font specific variables
    let textColor: UIColor = UIColor.blackColor()
    let textFont: UIFont = UIFont(name: "Helvetica Bold", size: 20)!
    
    //Setup the image context using the passed image.
    UIGraphicsBeginImageContext(inImage.size)
    
    //Setups up the font attributes that will be later used to dictate how the text should be drawn
    let textFontAttributes = [
      NSFontAttributeName: textFont,
      NSForegroundColorAttributeName: textColor,
    ]
    
    //Put the image into a rectangle as large as the original image.
    inImage.drawInRect(CGRectMake(0, 0, inImage.size.width, inImage.size.height))
    
    // Creating a point within the space that is as bit as the image.
    let rect: CGRect = CGRectMake(atPoint.x, atPoint.y, inImage.size.width, inImage.size.height)
    
    //Now Draw the text into an image.
    drawText.drawInRect(rect, withAttributes: textFontAttributes)
    
    // Create a new image out of the images we have created
    let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
    
    // End the context now that we have the image we need
    UIGraphicsEndImageContext()
    
    //And pass it back up to the caller.
    return newImage
    
  }
}