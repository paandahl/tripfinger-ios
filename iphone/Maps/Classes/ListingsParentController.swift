import Foundation

class ListingsParentController: UIViewController {
  
  var mapButton: UIBarButtonItem!

  let countryDownloadId: String
  var offline: Bool

  init(countryDownloadId: String, offline: Bool) {
    self.countryDownloadId = countryDownloadId
    self.offline = offline
    super.init(nibName: nil, bundle: nil)
    addObserver(DatabaseService.TFCountrySavedNotification, selector: #selector(countryDownloaded(_:)))
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let searchButton = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: #selector(navigateToSearch))
    mapButton = UIBarButtonItem(image: UIImage(named: "maps_icon"), style: .Plain, target: self, action: #selector(navigateToMap))
    mapButton.accessibilityLabel = "Map"
    if !offline {
      mapButton.tintColor = UIColor.whiteColor().colorWithAlphaComponent(0.4)
    }
    navigationItem.rightBarButtonItems = [searchButton, mapButton]
    view.backgroundColor = UIColor.whiteColor()
  }
  
  func showAlertWhenGuideIsNotDownloaded() {
    let alert: UIAlertView
    if DownloadService.isCountryDownloading(countryDownloadId) {
      alert = UIAlertView(title: "", message: "Country is still downloading.", delegate: self, cancelButtonTitle: "Ok", otherButtonTitles: "View progress")
    } else {
      alert = UIAlertView(title: "", message: "You need to download the country to view listings on the map.", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Download now")
    }
    alert.show()
  }
  
  func countryDownloaded(notification: NSNotification) {
    let countryName = notification.object as! String
    let country = DatabaseService.getCountry(countryName)!
    if country.getDownloadId() == countryDownloadId {
      offline = true
      mapButton.tintColor = UIColor.whiteColor().colorWithAlphaComponent(1)
    }
  }
  
  func navigateToSearch() {
    let vc = MapsAppDelegateWrapper.getMapViewController()
    navigationController!.pushViewController(vc, animated: true)
    MapsAppDelegateWrapper.openSearch()
  }
  
  func navigateToMap() {
    LogUtils.assertionFailAndRemoteLog("navigateToMap not implemented in class: \(self)")
  }
}

extension ListingsParentController: UIAlertViewDelegate {
  
  func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
    if buttonIndex == 1 {
      MapsAppDelegateWrapper.openDownloads(countryDownloadId, navigationController: navigationController)
    }
  }
}