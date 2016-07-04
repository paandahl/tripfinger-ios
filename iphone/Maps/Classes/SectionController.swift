import RealmSwift
import Firebase

class SectionController: GuideItemController {
  
  var section: GuideText
  weak var mapNavigator: MapNavigator!
  
  init(section: GuideText, mapNavigator: MapNavigator) {
    self.section = section
    self.mapNavigator = mapNavigator
    super.init(guideItem: section.item)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = section.getName()

    guideItemExpanded = true
    if section.item.loadStatus != GuideItem.LoadStatus.FULLY_LOADED {
      ContentService.getGuideTextWithId(section.getId(), failure: showErrorHud) { section in
        self.section = section
        self.updateUI()
      }
    }
  }
  
  override func updateUI() {
    populateTableSections()
    tableView.reloadData {}
  }
}

// MARK: - Table data source
extension SectionController {
  
  override func populateTableSections() {
    tableSections = [TableSection]()
    if section.item.content != nil {
      let section = TableSection(cellIdentifier: TableCellIdentifiers.guideItemCell)
      section.elements.append(("", ""))
      tableSections.append(section)
    }
    
    if guideItemExpanded {
      let textsSection = TableSection(cellIdentifier: TableCellIdentifiers.rightDetailCell, target: self, selector: #selector(navigateToSection))
      
      for guideSection in section.item.guideSections {
        textsSection.elements.append((title: guideSection.item.name, value: guideSection))
      }
      tableSections.append(textsSection)
    }
  }

  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let section = tableSections[indexPath.section]
    if section.cellIdentifier == TableCellIdentifiers.guideItemCell {
      let cell = GuideItemCell()
      cell.delegate = self
      cell.setContentFromGuideItem(self.section.item)
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
      }
      else {
        cell.textLabel!.text = section.elements[indexPath.row].0
      }
      return cell
    }
  }

  override func licenseClicked() {
    if section.item.textLicense == nil || section.item.textLicense == "" {
      let licenseController = LicenseController(guideItem: section.item)
      navigationController!.pushViewController(licenseController, animated: true)
    } else {
      super.licenseClicked()
    }
  }
  
  func navigateToSection(object: AnyObject) {
    let section = object as! GuideText
    let sectionController = SectionController(section: section, mapNavigator: mapNavigator)
    navigationController!.pushViewController(sectionController, animated: true)
    FIRAnalytics.logEventWithName(kFIREventSelectContent, parameters: [
      kFIRParameterContentType: "section",
      kFIRParameterItemID: section.getName() + "(\(section.getId()))"
      ])
  }
  
  override func navigateToMap() {
    mapNavigator.navigateToMap()
  }
}