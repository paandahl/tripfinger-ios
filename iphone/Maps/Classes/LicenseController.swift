import Foundation

class LicenseController: UIViewController {
  
  let imageLicenseHeader = UILabel()
  let imageLicenseTitle = UILabel()
  let imageLicenseText = UILabel()
  let imageArtistTitle = UILabel()
  let imageArtistText = UILabel()
  let imageUrlTitle = UILabel()
  let imageUrlButton = UIButton()
  let textLicenseHeader = UILabel()
  let textLicenseText = UITextView()
  let noteHeader = UILabel()
  let noteText = UITextView()
  
  let textItem: GuideItem
  let imageItem: GuideItem
  
  init(textItem: GuideItem, imageItem: GuideItem) {
    self.textItem = textItem
    self.imageItem = imageItem
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    navigationItem.title = "License"
    view.backgroundColor = UIColor.whiteColor()
    textLicenseHeader.text = "Text license"
    textLicenseHeader.font = UIFont.boldSystemFontOfSize(17.0)
    view.addSubview(textLicenseHeader)
    imageLicenseHeader.font = UIFont.boldSystemFontOfSize(17.0)
    view.addSubview(imageLicenseHeader)

    if imageItem.images.count > 0 {
      let image = imageItem.images[0]
      imageLicenseHeader.text = "Image rights"
      imageLicenseHeader.font = UIFont.boldSystemFontOfSize(16.0)
      view.addSubview(imageLicenseHeader)
      imageLicenseTitle.text = "License:"
      imageLicenseTitle.font = UIFont.boldSystemFontOfSize(14.0)
      view.addSubview(imageLicenseTitle)
      imageLicenseText.text = image.license
      imageLicenseText.font = UIFont.systemFontOfSize(14.0)
      view.addSubview(imageLicenseText)
      imageArtistTitle.text = "Artist:"
      imageArtistTitle.font = UIFont.boldSystemFontOfSize(14.0)
      view.addSubview(imageArtistTitle)
      imageArtistText.text = image.artist
      imageArtistText.font = UIFont.systemFontOfSize(14.0)
      imageArtistText.lineBreakMode = .ByWordWrapping
      imageArtistText.numberOfLines = 2
      view.addSubview(imageArtistText)
      imageUrlTitle.text = "Link:"
      imageUrlTitle.font = UIFont.boldSystemFontOfSize(14.0)
      view.addSubview(imageUrlTitle)
      if image.originalUrl != nil && image.originalUrl != "" {
        imageUrlButton.setTitle("Click here", forState: .Normal)
        imageUrlButton.addTarget(self, action: "navigateToImage", forControlEvents: .TouchUpInside)
      } else {
        imageUrlButton.setTitle("None", forState: .Normal)
        imageUrlButton.enabled = false
      }
      imageUrlButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
      imageUrlButton.setTitleColor(UIColor.grayColor(), forState: .Disabled)
      imageUrlButton.titleLabel!.font = UIFont.systemFontOfSize(14.0)
      imageUrlButton.sizeToFit()
      view.addSubview(imageUrlButton)
      
      let views = ["imgLicenseH": imageLicenseHeader, "imgLicenseT": imageLicenseTitle, "imgLicenseTxt": imageLicenseText,
        "imgArtistT": imageArtistTitle, "imgArtistTxt": imageArtistText, "imgUrlT": imageUrlTitle, "imgUrlTxt": imageUrlButton,
        "txtLicenseH": textLicenseHeader]
      view.addConstraints("V:|-20-[imgLicenseH]-20-[imgLicenseT]-10-[imgArtistT]", forViews: views)
      view.addConstraints("V:[imgArtistTxt]-10-[imgUrlT]-20-[txtLicenseH]", forViews: views)
      view.addConstraints("V:[imgLicenseH]-20-[imgLicenseTxt]-10-[imgArtistTxt]-5-[imgUrlTxt]", forViews: views)
      
      view.addConstraints("H:|-10-[imgLicenseH]", forViews: views)
      view.addConstraints("H:|-10-[imgLicenseT]", forViews: views)
      view.addConstraints("H:|-100-[imgLicenseTxt]", forViews: views)
      view.addConstraints("H:|-10-[imgArtistT]", forViews: views)
      view.addConstraints("H:|-100-[imgArtistTxt]-2-|", forViews: views)
      view.addConstraints("H:|-10-[imgUrlT]", forViews: views)
      view.addConstraints("H:|-100-[imgUrlTxt]", forViews: views)
    } else {
      view.addConstraints("V:|-20-[txtLicenseH]", forViews: ["txtLicenseH": textLicenseHeader])
    }
    
    if let textLicense = textItem.textLicense {
      let encodedData = textLicense.dataUsingEncoding(NSUTF8StringEncoding)!
      let options : [String: AnyObject] = [
        NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
        NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding,
      ]
      let attributedString = try! NSMutableAttributedString(data: encodedData, options: options, documentAttributes: nil)
      attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(14.0), range: NSMakeRange(0, attributedString.length))
      let style = NSMutableParagraphStyle()
      style.lineSpacing = 5
      style.paragraphSpacing = 20
      attributedString.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, attributedString.length))
      textLicenseText.attributedText = attributedString
    } else {
      textLicenseText.text = "License is not yet specified for section."
    }
    textLicenseText.sizeToFit()
    textLicenseText.editable = false
    textLicenseText.scrollEnabled = false

    view.addSubview(textLicenseText)
    
    noteHeader.text = "Note"
    noteHeader.font = UIFont.boldSystemFontOfSize(17.0)
    view.addSubview(noteHeader)
    
    noteText.text = "Each section and each image have their own license. So, within a given region, the different parts can have separate licenses."
    noteText.font = UIFont.systemFontOfSize(14.0)
    view.addSubview(noteText)
    
    let views = ["txtLicenseH": textLicenseHeader, "txtLicenseTxt": textLicenseText, "noteH": noteHeader, "noteTxt": noteText]
    view.addConstraints("V:[txtLicenseH]-20-[txtLicenseTxt]-20-[noteH]-20-[noteTxt(60)]", forViews: views)
    view.addConstraints("H:|-10-[txtLicenseH]", forViews: views)
    view.addConstraints("H:|-10-[txtLicenseTxt]-10-|", forViews: views)
    view.addConstraints("H:|-10-[noteH]", forViews: views)
    view.addConstraints("H:|-10-[noteTxt]-10-|", forViews: views)
  }
  
  func navigateToImage() {
    let urlString = imageItem.images[0].originalUrl!
    let url = NSURL(string: urlString)
    if let url = url {
      UIApplication.sharedApplication().openURL(url)
    } else {
      let alert = UIAlertController(title: "Error opening URL", message: "Url was not valid: \(urlString)", preferredStyle: UIAlertControllerStyle.Alert)
      let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
      alert.addAction(alertAction)
      presentViewController(alert, animated: true, completion: nil)
    }
  }
}