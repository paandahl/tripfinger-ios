import Foundation

extension String {
  
  func splitInParagraphs() -> [String] {
    var paragraphs = [String]()
    var paragraphStart = self.startIndex
    var paragraphEnd = self.rangeOfString("</p>")
    while paragraphEnd != nil {
      let paragraphRange = Range<String.Index>(start: paragraphStart, end: paragraphEnd!.endIndex)
      paragraphs.append(self.substringWithRange(paragraphRange))
      paragraphStart = paragraphEnd!.endIndex
      let restOfTextRange = Range<String.Index>(start: paragraphEnd!.endIndex, end: self.endIndex)
      paragraphEnd = self.rangeOfString("</p>", range: restOfTextRange)
    }
    return paragraphs
  }
 
  func attributedString(fontSize: CGFloat, paragraphSpacing: CGFloat = 20) -> NSMutableAttributedString {
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
    style.paragraphSpacing = paragraphSpacing
    attributedString.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, attributedString.length))
    return attributedString
  }
}