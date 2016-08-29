import Foundation

class SettingsButton: UIBarButtonItem {
  
  weak var parent: UIViewController!
  let navigateToSearch: () -> ()
  
  init(parent: UIViewController, navigateToSearch: () -> ()) {
    self.parent = parent
    self.navigateToSearch = navigateToSearch
    super.init()
    customView = UIImageView(image: UIImage(named: "ic_menu"))
    let tap = UITapGestureRecognizer(target: self, action: #selector(openMenu))
    customView!.addGestureRecognizer(tap)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func openMenu() {
    let settingsDropdown = SettingsDropdown(closeMenu: closeMenu, navigateToSearch: navigateToSearch, parent: parent)
    settingsDropdown.modalPresentationStyle = .OverFullScreen
    parent.navigationController!.presentViewController(settingsDropdown, animated: false, completion: nil)
    let imageView = customView as! UIImageView
    imageView.image = UIImage(named: "ic_menu_up")
  }
  
  func closeMenu() {
    let imageView = customView as! UIImageView
    imageView.image = UIImage(named: "ic_menu")
  }
}