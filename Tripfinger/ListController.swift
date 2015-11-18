//
//  ListController.swift
//  Tripfinger
//
//  Created by Preben Ludviksen on 23/10/15.
//  Copyright © 2015 Preben Ludviksen. All rights reserved.
//

import Foundation

class ListController: UITableViewController, SubController {
  struct TableViewCellIdentifiers {
    static let listingCell = "ListingCell"
  }
  
  var session: Session!
  var filterBox: FilterBox!
  var category: Attraction.Category!
  
  override func viewDidLoad() {
    UINib.registerNib(TableViewCellIdentifiers.listingCell, forTableView: tableView)
    
    filterBox = UINib(nibName: "FilterBox", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! FilterBox
    filterBox.delegate = self
    let headerView = UIView()
    headerView.addSubview(filterBox)
    headerView.addConstraints("V:|-10-[filters(44)]", forViews: ["filters": filterBox])
    headerView.addConstraints("H:|-0-[filters]-0-|", forViews: ["filters": filterBox])
    var headerFrame = headerView.frame;
    headerFrame.size.height = 44;
    headerView.frame = headerFrame;
    tableView.tableHeaderView = headerView
    
    session.loadBrusselsAsCurrentRegionIfEmpty() {
      self.loadAttractions()
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    if category != session.currentCategory {
      loadAttractions()
    }
  }
  
  func loadAttractions() {
    category = session.currentCategory
    filterBox.regionNameLabel.text = "\(session.currentRegion!.listing.item.name!):"
    filterBox.categoryLabel.text = session.currentCategory.entityName
    session.loadAttractions() {
      loaded in
      
      if loaded {
        self.tableView.reloadData()
      }
    }
  }
  
  override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showDetail" {
      let detailController = segue.destinationViewController as! DetailController
      detailController.attraction = sender as! Attraction
    }
    else if segue.identifier == "showFilter" {
      let navigationController = segue.destinationViewController as! UINavigationController
      let filterController = navigationController.viewControllers[0] as! FilterController
      filterController.session = session
      filterController.delegate = self
    }
  }
}

// MARK: - Table View Data Source
extension ListController {
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return session.currentAttractions.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.listingCell, forIndexPath: indexPath) as! ListingCell
    let attraction = session.currentAttractions[indexPath.row]
    cell.setContent(attraction)
    cell.delegate = self
    return cell
  }
}

extension ListController: ListingCellContainer {
  
  func showDetail(attraction: Attraction) {
    performSegueWithIdentifier("showDetail", sender: attraction)
  }
}

extension ListController: FilterBoxDelegate {
  
  func filterClick() {
    performSegueWithIdentifier("showFilter", sender: nil)
  }
}

extension ListController: FilterControllerDelegate {
  
  func filterChanged() {
    dismissViewControllerAnimated(true, completion: nil)
    viewWillAppear(true)
  }
}