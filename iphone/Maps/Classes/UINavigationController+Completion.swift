import Foundation

extension UINavigationController {
  
  func pushViewController(viewController: UIViewController,
                          animated: Bool, completion: (Void -> Void)?) {
    
    CATransaction.begin()
    if let completion = completion {
      CATransaction.setCompletionBlock(completion)
    }
    pushViewController(viewController, animated: animated)
    CATransaction.commit()
  }
}