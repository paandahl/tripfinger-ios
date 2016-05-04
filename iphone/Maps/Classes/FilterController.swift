import Foundation

protocol FilterControllerDelegate: class {
  func filterChanged()
}

class FilterController: UITableViewController {
  
  var delegate: FilterControllerDelegate!
  var session: Session!
  var selectedCell: UITableViewCell!
  
  @IBAction func close() {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func done() {
    delegate.filterChanged()
  }
  
  override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.section == 1 && indexPath.row == Listing.Category.allValues.indexOf(session.currentCategory) {
      cell.selected = true
      selectedCell = cell
    }
  }
  
  override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask.Portrait
  }

}

// MARK: - Table View Data Source
extension FilterController {
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 3
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    switch section {
    case 0:
      return 1
    case 1:
      return Listing.Category.allValues.count
    case 2:
      return 0
    default:
      return 0
    }
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0:
      return "Region"
    case 1:
      return "Categories"
    case 2:
      return "Subcategories"
    default:
      return ""
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    switch indexPath.section {
    case 0:
      let cell = tableView.dequeueReusableCellWithIdentifier("regionCell", forIndexPath: indexPath)
      cell.textLabel?.text = "Brussels"
      return cell
    case 1:
      let cell = tableView.dequeueReusableCellWithIdentifier("categoryCell", forIndexPath: indexPath)
      cell.textLabel?.text = Listing.Category.allValues[indexPath.row].entityName
      return cell
    case 2:
      let cell = tableView.dequeueReusableCellWithIdentifier("subCategoryCell", forIndexPath: indexPath)
      return cell
    default:
      return UITableViewCell()
    }
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    switch indexPath.section {
    case 0:
      return
    case 1:
      session.currentCategory = Listing.Category.allValues[indexPath.row]
      selectedCell.selected = false
    case 2:
      return
    default:
      return
    }
  }
}