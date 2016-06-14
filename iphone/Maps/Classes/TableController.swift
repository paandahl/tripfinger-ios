import Foundation

class TableController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  var adjustedInsets = false
  weak var tableView : UITableView!
  
  struct TableCellIdentifiers {
    static let guideItemCell = "GuideItemCell"
    static let textMessageCell = "TextMessageCell"
    static let rightDetailCell = "RightDetailCell"
    static let listingCell = "ListingCell"
    static let likedCell = "LikedListingCell"
    static let loadingCell = "LoadingCell"
  }
  
  var tableSections = [TableSection]()
  
  override func loadView() { // *
    print("loading view for tableController")
    view = UITableView(frame: CGRectZero, style: .Grouped)
    tableView = self.view as! UITableView
    tableView.delegate = self
    tableView.dataSource = self
    UINib.registerClass(RightDetailCell.self, reuseIdentifier: TableCellIdentifiers.rightDetailCell, forTableView: tableView)
    UINib.registerClass(ListingCell.self, reuseIdentifier: TableCellIdentifiers.likedCell, forTableView: tableView)
    UINib.registerClass(ListingCell.self, reuseIdentifier: TableCellIdentifiers.listingCell, forTableView: tableView)
    UINib.registerClass(TextMessageCell.self, reuseIdentifier: TableCellIdentifiers.textMessageCell, forTableView: tableView)
    UINib.registerNib(TableCellIdentifiers.loadingCell, forTableView: tableView)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    automaticallyAdjustsScrollViewInsets = true
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 44.0;
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return tableSections.count;
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tableSections[section].elements.count;
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if let title = tableSections[section].title {
      return title
    }
    else {
      return nil
    }
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    let section = tableSections[indexPath.section];
    if let handler = section.handler {
      handler(section.elements[indexPath.row].1)
    }
    
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    print("default")
    return UITableViewCell()
  }
}