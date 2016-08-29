import Foundation

class SettingsDropdown: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  weak var parent: UIViewController!
  var tableView : UITableView!
  var dimBackground: UIView?
  let numCells = 2;
  let cellHeight = 44;
  let closeMenu: () -> ()
  let navigateToSearch: () -> ()
    
  init(closeMenu: () -> (), navigateToSearch: () -> (), parent: UIViewController) {
    self.parent = parent
    self.closeMenu = closeMenu
    self.navigateToSearch = navigateToSearch
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    let isLandScape = UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation);
    let navbarHeight = isLandScape ? CGFloat(52) : CGFloat(64)
    let screenWidth = UIScreen.mainScreen().nativeBounds.width
    let transparentButton = UIView(frame: CGRectMake(0, 0, screenWidth, navbarHeight))
    tableView = UITableView(frame: CGRectMake(0, navbarHeight, screenWidth, 0), style: .Plain)
    tableView.delegate = self
    tableView.dataSource = self
    view.backgroundColor = UIColor.clearColor()
    tableView.backgroundColor = UIColor.clearColor()
    dimBackground = UIView(frame: CGRectMake(0, navbarHeight, screenWidth, parent.view.bounds.height - navbarHeight))
    dimBackground!.backgroundColor = UIColor.fadeBackground()
    dimBackground!.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
    var tap = UITapGestureRecognizer(target: self, action: #selector(dimTapped))
    dimBackground!.addGestureRecognizer(tap)
    tap = UITapGestureRecognizer(target: self, action: #selector(dimTapped))
    transparentButton.addGestureRecognizer(tap)

    view.addSubview(transparentButton)
    view.addSubview(tableView)
    view.insertSubview(dimBackground!, belowSubview: tableView!)
    
    dimBackground!.alpha = 0.0
  }
  
  override func viewDidAppear(animated: Bool) {
    UIView.animateWithDuration(0.2, animations: {
      self.dimBackground!.alpha = 0.8
      var frame = self.tableView.frame
      frame.size.height += CGFloat(self.numCells * self.cellHeight)
      self.tableView.frame = frame
      }, completion: nil)
  }
  
  func dimTapped() {
    closeMenu()
    dimBackground!.alpha = 0.8
    UIView.animateWithDuration(0.2, animations: {
      self.dimBackground!.alpha = 0.0
      var frame = self.tableView.frame;
      frame.size.height  = 0
      self.tableView.frame = frame
    }) { _ in
      self.dismissViewControllerAnimated(false, completion: nil)
    }
  }
  
  func closeStraight() {
    closeMenu()
    dismissViewControllerAnimated(false, completion: nil)
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return numCells
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let nib = UINib(nibName: "SettingsDropdownCell",bundle: nil)
    let cell = nib.instantiateWithOwner(nil, options: nil)[0] as! SettingsDropdownCell
    
    switch indexPath.row {
    case 0:
      cell.settingLabel.text = "Search"
      cell.settingSymbol.image = UIImage(named: "ic_menu_search")
    case 1:
      cell.settingLabel.text = "Settings"
      cell.settingSymbol.image = UIImage(named: "ic_menu_settings")!.imageWithRenderingMode(.AlwaysTemplate)
    default:
      fatalError("Cell not accounted for.")
    }
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    closeStraight()
    switch indexPath.row {
    case 0:
      navigateToSearch()
    case 1:
      TripfingerAppDelegate.navigationController.openSettings()
    default:
      fatalError("Cell not accounted for.")
    }
  }
}