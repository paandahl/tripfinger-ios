import Foundation


class CountryListController: TableController {
  
  let refreshControl = UIRefreshControl()
  var countryLists = [(String, List<Region>)]()
  var worldAreaImageSet = Set<String>()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.title = "Countries"
    let mapButton = UIBarButtonItem(image: UIImage(named: "maps_icon"), style: .Plain, target: self, action: #selector(navigateToMap))
    mapButton.accessibilityLabel = "Map"
    let searchButton = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: #selector(navigateToSearch))
    navigationItem.rightBarButtonItems = [searchButton, mapButton]

    if TripfingerAppDelegate.mode != TripfingerAppDelegate.AppMode.TEST {
      refreshControl.addTarget(self, action: #selector(loadCountryLists), forControlEvents: .ValueChanged)
      tableView.addSubview(refreshControl)
    }
    loadCountryLists()
    
    addObserver(DatabaseService.TFCountrySavedNotification, selector: #selector(countryInvalidated))
    addObserver(DatabaseService.TFCountryDeletedNotification, selector: #selector(countryInvalidated))
    
    dispatch_async(dispatch_get_main_queue()) {
      MapsAppDelegateWrapper.getMapViewController().view.layoutSubviews()
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    if countryLists.isEmpty {
      loadCountryLists()
    }
  }
  
  func updateUI() {
    populateTableSections()
    tableView.reloadData {}
    refreshControl.endRefreshing()
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
    } else {
      countryLists = makeCountryLists(Array(DatabaseService.getCountries()))
      updateUI()
    }
  }
  
  private func getCountryList(worldArea: String, countryLists: [(String, List<Region>)]) -> List<Region>? {
    for (area, countryList) in countryLists {
      if area == worldArea {
        return countryList
      }
    }
    return nil
  }
  
  private func makeCountryLists(countries: [Region]) -> [(String, List<Region>)] {
    var countryLists = [(String, List<Region>)]()
    var betaCountries = [(Region, List<Region>)]()
    for country in countries {
      var countryList = getCountryList(country.listing.worldArea!, countryLists: countryLists)
      if countryList == nil {
        countryList = List<Region>()
        countryLists.append((country.listing.worldArea!, countryList!))
      }
      if country.item().status == 0 {
        betaCountries.append((country, countryList!))
      } else {
        countryList!.append(country)
      }
    }
    for (country, list) in betaCountries {
      list.append(country)
    }
    return countryLists
  }
  
  
  func populateTableSections() {
    tableSections = [TableSection]()
    
    if !NetworkUtil.connectedToNetwork() && countryLists.count == 0 {
      let section = TableSection(cellIdentifier: TableCellIdentifiers.textMessageCell, handler: nil)
      section.elements.append((title: "", value: ""))
      tableSections.append(section)
    } else {
      for (regionName, countryList) in countryLists {
        let section = TableSection(title: regionName, cellIdentifier: TableCellIdentifiers.rightDetailCell, handler: navigateToRegion)
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
    let libPath = NSURL.getDirectory(.LibraryDirectory)
    let imagePath = libPath.URLByAppendingPathComponent(title! + ".jpeg")
    let image = UIImageView(frame: CGRectMake(0, 0, tableView.frame.size.width, 150))
    image.contentMode = .ScaleAspectFill
    image.clipsToBounds = true
    if NSURL.fileExists(imagePath) {
      image.image = UIImage(data: NSData(contentsOfURL: imagePath)!)
    } else if !worldAreaImageSet.contains(title!) {
      worldAreaImageSet.insert(title!)
      var imageUrl = DownloadService.gcsImagesUrl + title! + ".jpeg"
      imageUrl = imageUrl.stringByReplacingOccurrencesOfString(" ", withString: "%20")
      NetworkUtil.saveDataFromUrl(imageUrl, destinationPath: imagePath) {
        dispatch_async(dispatch_get_main_queue()) {
          image.image = UIImage(data: NSData(contentsOfURL: imagePath)!)          
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
    view.addSubview(image)
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
  }
  
  func navigateToMap() {
    let vc = MapsAppDelegateWrapper.getMapViewController()
    navigationController!.pushViewController(vc, animated: true)
  }
  
  func navigateToSearch() {
    let vc = MapsAppDelegateWrapper.getMapViewController()
    navigationController!.pushViewController(vc, animated: true)
    MapsAppDelegateWrapper.openSearch()
  }
  
  func countryInvalidated() {
    countryLists = makeCountryLists(Array(DatabaseService.getCountries()))
    loadCountryLists()
  }
}