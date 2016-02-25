import Foundation

class TableController: UITableViewController {
  
  struct TableCellIdentifiers {
    static let guideItemCell = "GuideItemCell"
    static let textMessageCell = "TextMessageCell"
    static let rightDetailCell = "RightDetailCell"
    static let loadingCell = "LoadingCell"
  }
  
  var tableSections = [TableSection]()

  override func viewDidLoad() {
    UINib.registerClass(RightDetailCell.self, reuseIdentifier: TableCellIdentifiers.rightDetailCell, forTableView: tableView)
    UINib.registerClass(GuideItemCell.self, reuseIdentifier: TableCellIdentifiers.guideItemCell, forTableView: tableView)
    UINib.registerClass(TextMessageCell.self, reuseIdentifier: TableCellIdentifiers.textMessageCell, forTableView: tableView)
    UINib.registerNib(TableCellIdentifiers.loadingCell, forTableView: tableView)
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return tableSections.count;
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tableSections[section].elements.count;
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if let title = tableSections[section].title {
      return title
    }
    else {
      return nil
    }
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    let section = tableSections[indexPath.section];
    if let handler = section.handler {
      handler(section.elements[indexPath.row].1)
    }
    
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }

}