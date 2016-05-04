import Foundation

public extension UIImage {
  convenience init(withColor: UIColor, size: CGSize = CGSizeMake(1, 1)) {
    let rect = CGRectMake(0, 0, size.width, size.height)
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
    withColor.setFill()
    UIRectFill(rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    self.init(CGImage: image.CGImage!)
  }
  
  convenience init(withColor: UIColor, frame: CGRect) {
    UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
    withColor.setFill()
    UIRectFill(frame)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    self.init(CGImage: image.CGImage!)
  }

}