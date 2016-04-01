import Foundation

class RightDetailCell: UITableViewCell {
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .Value1, reuseIdentifier: reuseIdentifier)
  }
  
  override func prepareForReuse() {
    textLabel?.accessibilityLabel = nil
    textLabel?.accessibilityIdentifier = nil
    textLabel?.text = nil
  }
  
  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
}