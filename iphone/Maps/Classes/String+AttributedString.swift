import Foundation

extension String {
 
  func attributedString(fontSize: CGFloat) -> NSMutableAttributedString {
    let styledString = self.stringByAppendingString(String(format: "<style>body{font-family: '%@'; font-size:%fpx;}</style>", UIFont.systemFontOfSize(fontSize).fontName, fontSize))
    let encodedData = styledString.dataUsingEncoding(NSUTF8StringEncoding)!
    let options : [String: AnyObject] = [
      NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
      NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding,
    ]
    let attributedString = try! NSMutableAttributedString(data: encodedData, options: options, documentAttributes: nil)
//    attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(16.0), range: NSMakeRange(0, attributedString.length))
    let style = NSMutableParagraphStyle()
    style.lineSpacing = 5
    style.paragraphSpacing = 20
    attributedString.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, attributedString.length))
    return attributedString
  }
}