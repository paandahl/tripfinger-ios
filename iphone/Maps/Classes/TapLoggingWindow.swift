import Foundation

class TapLoggingWindow: UIWindow {
  
  private let tapLoggingEnabled: Bool
  
  init(tapLoggingEnabled: Bool, frame: CGRect) {
    self.tapLoggingEnabled = tapLoggingEnabled
    super.init(frame: frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
    if tapLoggingEnabled {
      print("Registered tap on point: \(point)")
    }
    return super.hitTest(point, withEvent: event)
  }
}
