import Foundation

class TextMessageCell: UITableViewCell {
  
  var textView = UITextView()
  
  override required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    textView.font = UIFont.systemFontOfSize(18)
    contentView.addSubview(textView)
    let views = ["message": textView]
    contentView.addConstraints("V:|-10-[message(60)]-10-|", forViews: views)
    contentView.addConstraints("H:|-10-[message]-10-|", forViews: views)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func setTextMessage(text: String) {
    textView.text = text;
  }
}