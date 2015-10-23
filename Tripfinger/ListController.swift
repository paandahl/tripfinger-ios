//
//  ListController.swift
//  Tripfinger
//
//  Created by Preben Ludviksen on 23/10/15.
//  Copyright © 2015 Preben Ludviksen. All rights reserved.
//

import Foundation

class ListController: UITableViewController {
    struct TableViewCellIdentifiers {
        static let listingCell = "ListingCell"
    }
    
    var session: Session!

    override func viewDidLoad() {
        UINib.registerNib(TableViewCellIdentifiers.listingCell, forTableView: tableView)
        
        session.loadBrusselsAsCurrentRegionIfEmpty() {
            self.session.loadAttractions() {
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