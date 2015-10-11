import UIKit

class ImagelabelView: UIView{
    var imageView: UIImageView!
    var label: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        imageView = UIImageView()
        label = UILabel()
    }
    
    init(frame: CGRect, image: UIImage, text: String) {
        
        super.init(frame: frame)
        constructImageView(image)
        constructLabel(text)
    }
    
    func constructImageView(image:UIImage) -> Void{
        
        let topPadding:CGFloat = 10.0
        
        let framex = CGRectMake(floor((CGRectGetWidth(self.bounds) - image.size.width)/2),
            topPadding,
            image.size.width,
            image.size.height)
        imageView = UIImageView(frame: framex)
        imageView.image = image
        addSubview(self.imageView)
    }
    
    func constructLabel(text:String) -> Void{
        var height:CGFloat = 18.0
        let frame2 = CGRectMake(0,
            CGRectGetMaxY(self.imageView.frame),
            CGRectGetWidth(self.bounds),
            height);
        self.label = UILabel(frame: frame2)
        label.text = text
        addSubview(label)
        
    }
}