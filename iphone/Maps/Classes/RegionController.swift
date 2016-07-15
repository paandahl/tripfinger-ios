import RealmSwift
import MBProgressHUD
import Firebase

protocol MapNavigator: class {
  func navigateToMap()
}

class RegionController: GuideItemController, MapNavigator {
  
  var countryMwmId: String
  var region: Region
  
  init(region: Region, countryMwmId: String? = nil) {
    self.region = region
    if let countryMwmId = countryMwmId {
      self.countryMwmId = countryMwmId
    } else {
      self.countryMwmId = region.getDownloadId()
    }
    super.init(guideItem: region.item())
    navigationItem.title = region.getName()
    addObserver(DatabaseService.TFCountrySavedNotification, selector: #selector(countryDownloaded(_:)))
    addObserver(DatabaseService.TFCountryDeletedNotification, selector: #selector(countryDeleted(_:)))
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    loadRegionIfNecessary()
  }
  
  func loadRegionIfNecessary() {
    let failure = {
      self.delay(2, selector: #selector(self.loadRegionIfNecessary))
    }
    if region.item().loadStatus != GuideItem.LoadStatus.FULLY_LOADED {
      ContentService.getRegionWithSlug(region.getSlug(), failure: failure) { region in
        self.region = region
        self.updateUI()
      }
    }
  }
      
  override func updateUI() {
    populateTableSections()
    tableView.reloadData {}
  }
  
  override func downloadClicked() {
    MapsAppDelegateWrapper.openDownloads(region.getDownloadId(), navigationController: navigationController)
  }    
}

// MARK: - Table data source
extension RegionController {
  
  override func populateTableSections() {
    tableSections = [TableSection]()

    if region.item().loadStatus == GuideItem.LoadStatus.CONTENT_NOT_LOADED {
      let section = TableSection(cellIdentifier: TableCellIdentifiers.loadingCell)
      section.elements.append((title: "", value: ""))
      tableSections.append(section)
      return
    }
    
    let contentSection = TableSection(cellIdentifier: TableCellIdentifiers.guideItemCell)
    contentSection.elements.append(("", ""))
    tableSections.append(contentSection)
    
    if guideItemExpanded {
      let textsSection = TableSection(cellIdentifier: TableCellIdentifiers.rightDetailCell, target: self, selector: #selector(navigateToSection))
      for guideSection in region.item().guideSections {
        textsSection.elements.append((title: guideSection.item.name, value: guideSection))
      }
      tableSections.append(textsSection)
    }
    
    let attractionsSection = TableSection(cellIdentifier: TableCellIdentifiers.rightDetailCell, target: self, selector: #selector(navigateToCategory))
    let attractionsDesc = GuideText.constructCategoryDescription(Listing.Category.ATTRACTIONS, forRegion: region)
    attractionsSection.elements.append((title: Listing.Category.ATTRACTIONS.entityName, value: attractionsDesc))
    tableSections.append(attractionsSection)
    
    let subRegionsSection: TableSection
    let probablyHasChildren = region.item().loadStatus == GuideItem.LoadStatus.CHILDREN_NOT_LOADED && (region.getCategory() == Region.Category.COUNTRY || region.getCategory() == Region.Category.SUB_REGION)
    if probablyHasChildren || region.item().subRegions.count > 0 {
      let title: String
      switch region.getCategory() {
      case Region.Category.CONTINENT:
        title = "Countries:"
      case Region.Category.COUNTRY:
        title = "Destinations:"
      case Region.Category.SUB_REGION:
        title = "Destinations:"
      default:
        title = "Neighbourhoods:"
      }
      if probablyHasChildren {
        subRegionsSection = TableSection(title: title, cellIdentifier: TableCellIdentifiers.rightDetailCell)
      } else {
        subRegionsSection = TableSection(title: title, cellIdentifier: TableCellIdentifiers.rightDetailCell, target: self, selector: #selector(navigateToRegion))
      }
      
      if probablyHasChildren {
        subRegionsSection.elements.append((title: "Loading...", value: ""))
      } else {
        for subRegion in region.item().getSubRegions() {
          var itemName = subRegion.listing.item.name
          let range = itemName.rangeOfString("/")
          if range != nil {
            itemName = itemName.substringFromIndex(range!.endIndex)
          }
          subRegionsSection.elements.append((title: itemName, value: subRegion))
        }
      }
      tableSections.append(subRegionsSection)
    }
    
    let categoriesSection = TableSection(title: "Directory", cellIdentifier: TableCellIdentifiers.rightDetailCell, target: self, selector: #selector(navigateToCategory))
    for categoryDesc in region.item().allCategoryDescriptions {
      let category = Listing.Category(rawValue: categoryDesc.item.category)!
      categoriesSection.elements.append((title: category.entityName, value: categoryDesc))
    }
    tableSections.append(categoriesSection)
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let section = tableSections[indexPath.section]
    if section.cellIdentifier == TableCellIdentifiers.guideItemCell {
      let cell = GuideItemCell()
      cell.delegate = self
      cell.setContentFromRegion(region)
      if (guideItemExpanded) {
        cell.expand()
      }
      cell.setNeedsUpdateConstraints()
      return cell
      
    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier(section.cellIdentifier, forIndexPath: indexPath)
      if cell.reuseIdentifier == TableCellIdentifiers.loadingCell {
        let indicator = cell.viewWithTag(1000) as! UIActivityIndicatorView
        indicator.startAnimating()
      } else if let cell = cell as? RightDetailCell where indexPath.row < section.elements.count {
        cell.textLabel!.text = section.elements[indexPath.row].0
        if let region = section.elements[indexPath.row].1 as? Region {
          cell.unfinishedLabel.hidden = region.item().status == 10
        }
      } else {
        // this is just for the application not to hang when we have race conditions
        // f.ex. you navigate to a region, the cell count is calculated, but before
        // rendering starts, the table is re-populated because the fetch finished fast.
        // in these cases we return empty cells, since a re-render is under way
        return UITableViewCell()
      }
      
      return cell
    }
  }    
}

// MARK: - Navigation
extension RegionController {
  
  func navigateToRegion(object: AnyObject) {
    let region = object as! Region
    let regionController = RegionController(region: region, countryMwmId: countryMwmId)
    navigationController!.pushViewController(regionController, animated: true)
    AnalyticsService.logSelectedRegion(region)
  }
  
  func navigateToCategory(object: AnyObject) {
    let categoryDescription = object as! GuideText
    let listingsController = ListingsController(regionId: region.getId(), countryMwmId: countryMwmId, categoryDescription: categoryDescription, regionLicense: region.item().textLicense, mapNavigator: self)
    navigationController!.pushViewController(listingsController, animated: true)
    AnalyticsService.logSelectedCategory(categoryDescription, region: region)
  }
  
  func navigateToSection(object: AnyObject) {
    let section = object as! GuideText
    let sectionController = SectionController(section: section, mapNavigator: self)
    navigationController!.pushViewController(sectionController, animated: true)
    AnalyticsService.logSelectedSection(section, region: region)
  }
  
  override func navigateToMap() {
    let vc = MapsAppDelegateWrapper.getMapViewController()
    navigationController!.pushViewController(vc, animated: true)
    FrameworkService.navigateToRegionOnMap(region)
  }
  
  func belongsToCountry(country: String) -> Bool {
    return region.listing.country == country || (region.getCategory() == Region.Category.COUNTRY && region.getName() == country)
  }
  
  func countryDownloaded(notifiction: NSNotification) {
    let country = notifiction.object as! String
    if belongsToCountry(country) {
      region = DatabaseService.getCountry(country)!
      updateUI()
    }
  }
  
  func countryDeleted(notification: NSNotification) {
    let country = notification.object as! String
    if belongsToCountry(country) {
      region = Region.constructRegion(country)
      updateUI()
    }
  }
}
