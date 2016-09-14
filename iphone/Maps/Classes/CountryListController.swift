import Foundation
import Firebase

class CountryListController: TableController {
  
  let refreshControl = UIRefreshControl()
  var countryLists = [(String, [Region])]()
  var worldAreaImageSet = Set<String>()
  weak var settingsButton: SettingsButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.title = "Countries"
    let mapButton = UIBarButtonItem(image: UIImage(named: "maps_icon")?.imageWithRenderingMode(.AlwaysTemplate), style: .Plain, target: self, action: #selector(navigateToMap))
    mapButton.accessibilityLabel = "Map"
    let settingsButton = SettingsButton(parent: self, navigateToSearch: navigateToSearch)
    let spacer = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
    spacer.width = 10;
    navigationItem.rightBarButtonItems = [settingsButton, spacer, mapButton]
    self.settingsButton = settingsButton

    if TripfingerAppDelegate.mode != TripfingerAppDelegate.AppMode.TEST {
      refreshControl.addTarget(self, action: #selector(loadCountryLists), forControlEvents: .ValueChanged)
      tableView.addSubview(refreshControl)
    }
    showLoadingHud(disableUserInteraction: false)
    loadCountryLists()
    
    addObserver(DatabaseService.TFCountrySavedNotification, selector: #selector(countryInvalidated))
    addObserver(DatabaseService.TFCountryDeletedNotification, selector: #selector(countryInvalidated))
    
    dispatch_async(dispatch_get_main_queue()) {
      let mapViewController = MapsAppDelegateWrapper.getMapViewController()
      mapViewController.view.layoutSubviews()
      let settingsButton = SettingsButton(parent: self, navigateToSearch: {
        MapsAppDelegateWrapper.openSearch(false)
      })
      mapViewController.navigationItem.rightBarButtonItems = [settingsButton]
    }
  }
  
  override func shouldAutorotate() -> Bool {
    return false
  }
  
  override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask.Portrait
  }
  
  override func viewWillAppear(animated: Bool) {
//    UIDevice.currentDevice().setValue(NSNumber(int: UIInterfaceOrientation.Portrait), forKey: "orientation")
//    [[UIDevice currentDevice] setValue:
//      [NSNumber numberWithInteger: UIInterfaceOrientationPortrait]
//      forKey:@"orientation"];
    if countryLists.isEmpty {
      loadCountryLists()
    }
  }
  
  func updateUI() {
    populateTableSections()
    tableView.reloadData {}
    refreshControl.endRefreshing()
    if countryLists.count > 0 {
      hideHuds()
    }
  }
  
  func loadCountryLists() {
    if NetworkUtil.connectedToNetwork() {
      let failure = { () -> () in
        self.delay(2, selector: #selector(self.loadCountryLists))
      }
      ContentService.getCountries(failure) {
        countries in
        
        for country in countries {
          country.item().loadStatus = GuideItem.LoadStatus.CHILDREN_NOT_LOADED
        }
        self.countryLists = self.makeCountryLists(countries)
        self.updateUI()
      }
    }
    countryLists = makeCountryLists(Array(DatabaseService.getCountries()))
    updateUI()
  }
  
  private func makeCountryLists(countries: [Region]) -> [(String, [Region])] {
    var countryDict = [String: [Region]]()
    for country in countries {
      if countryDict[country.listing.worldArea!] == nil {
        countryDict[country.listing.worldArea!] = []
      }
      countryDict[country.listing.worldArea!]!.append(country)
    }
    var countryLists = [(String, [Region])]()
    for (area, var countryList) in Array(countryDict).sort({$0.0 < $1.0}) {
      countryList.sortInPlace { $0.getName() < $1.getName() }
      countryLists.append((area, countryList))
    }
    return countryLists
  }
  
  
  func populateTableSections() {
    tableSections = [TableSection]()
    
    if !NetworkUtil.connectedToNetwork() && countryLists.count == 0 {
      let section = TableSection(cellIdentifier: TableCellIdentifiers.textMessageCell)
      section.elements.append((title: "", value: ""))
      tableSections.append(section)
      hideHuds()
    } else {
      for (regionName, countryList) in countryLists {
        let section = TableSection(title: regionName, cellIdentifier: TableCellIdentifiers.rightDetailCell, target: self, selector: #selector(navigateToRegion))
        for country in countryList {
          section.elements.append((title: country.listing.item.name!, value: country))
        }
        tableSections.append(section)
      }
    }
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let tableSection = tableSections[section]
    guard tableSection.cellIdentifier == TableCellIdentifiers.rightDetailCell else {
      return nil
    }
    let title = tableSections[section].title
    let view = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 160))
    let libPath = NSURL.getImageDirectory()
    let imagePath = libPath.URLByAppendingPathComponent(title! + ".jpeg")
    let image = UIImageView(frame: CGRectMake(0, 0, tableView.frame.size.width, 150))
    image.contentMode = .ScaleAspectFill
    image.clipsToBounds = true
    view.addSubview(image)
    if NSURL.fileExists(imagePath) {
      image.image = UIImage(data: NSData(contentsOfURL: imagePath)!)
    } else {
      let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
      indicator.startAnimating()
      indicator.center = image.center
      image.addSubview(indicator)
      if !worldAreaImageSet.contains(title!) {
        worldAreaImageSet.insert(title!)
        var imageUrl = DownloadService.gcsImagesUrl + title! + ".jpeg"
        imageUrl = imageUrl.stringByReplacingOccurrencesOfString(" ", withString: "%20")
        NetworkUtil.saveDataFromUrl(imageUrl, destinationPath: imagePath, failure: {}) {
          dispatch_async(dispatch_get_main_queue()) {
            indicator.removeFromSuperview()
            tableView.reloadData()
          }
        }
      }
    }
    let label = UILabel(frame: CGRectMake(10, 120, tableView.frame.size.width, 18))
    label.font = UIFont.boldSystemFontOfSize(18)
    label.textColor = UIColor.lightGrayColor()
    label.shadowColor = UIColor.blackColor()
    label.shadowOffset = CGSizeMake(0, 1)
    label.layer.shadowOpacity = 0.5
    let string = tableSections[section].title
    label.text = string
    view.addSubview(label)
    return view;
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    let tableSection = tableSections[section]
    return tableSection.cellIdentifier == TableCellIdentifiers.rightDetailCell ? 160 : 0
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let section = tableSections[indexPath.section]
    let cell = tableView.dequeueReusableCellWithIdentifier(section.cellIdentifier, forIndexPath: indexPath)
    if let cell = cell as? TextMessageCell {
      cell.setTextMessage("You are offline. Go online to view and download countries.")
    } else if let cell = cell as? RightDetailCell {
      cell.textLabel!.text = section.elements[indexPath.row].0
      let region = section.elements[indexPath.row].1 as! Region
      cell.unfinishedLabel.hidden = region.item().status == 10
    }
    return cell
  }
  
  // MARK: - Navigation
  
  func navigateToRegion(object: AnyObject) {
    let region = object as! Region
    let regionController = RegionController(region: region)
    navigationController!.pushViewController(regionController, animated: true)
    AnalyticsService.logSelectedRegion(region)
  }

  func navigateToMap() {
    AnalyticsService.logSelectedMapFromView("Frontpage")
    let vc = MapsAppDelegateWrapper.getMapViewController()
    navigationController!.pushViewController(vc, animated: true)
  }
  
  func navigateToSearch() {
    let vc = MapsAppDelegateWrapper.getMapViewController()
    navigationController!.pushViewController(vc, animated: true)
    MapsAppDelegateWrapper.openSearch(true)
  }
  
  func countryInvalidated() {
    countryLists = makeCountryLists(Array(DatabaseService.getCountries()))
    loadCountryLists()
  }
}