import Foundation

class RightDetailCell: UITableViewCell {
  
  let unfinishedLabel = UILabel(frame: CGRectMake(UIScreen.mainScreen().bounds.width - 120, 10, 100, 25))
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .Value1, reuseIdentifier: reuseIdentifier)
    unfinishedLabel.backgroundColor = UIColor.lightGrayColor()
    unfinishedLabel.textColor = UIColor.whiteColor()
    unfinishedLabel.text = "Unfinished"
    unfinishedLabel.font = UIFont.systemFontOfSize(11)
    unfinishedLabel.textAlignment = .Center
    unfinishedLabel.clipsToBounds = true
    unfinishedLabel.layer.cornerRadius = 8.0
    unfinishedLabel.hidden = true
    addSubview(unfinishedLabel)
  }
  
  override func prepareForReuse() {
    unfinishedLabel.hidden = true
    textLabel?.accessibilityLabel = nil
    textLabel?.accessibilityIdentifier = nil
    textLabel?.text = nil
  }
  
  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
}