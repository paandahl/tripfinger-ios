//
//  SearchViewController.swift
//  Tripfinger
//
//  Created by Preben Ludviksen on 19/10/15.
//  Copyright © 2015 Preben Ludviksen. All rights reserved.
//

import Foundation

class SearchViewController: UITableViewController {

    var searchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let searchBar:UISearchBar = UISearchBar(frame: CGRectMake(0, 0, 200, 20))
//        let searchBarItem = UIBarButtonItem(customView: searchBar)
//        self.navigationItem.leftBarButtonItem = searchBarItem;
//        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        
        // Make sure the that the search bar is visible within the navigation bar.
        searchController.searchBar.sizeToFit()
        
        // Include the search controller's search bar within the table's header view.
        let searchBarItem = UIBarButtonItem(customView: searchController.searchBar)
        self.navigationItem.leftBarButtonItem = searchBarItem
//
//        tableView.tableHeaderView = searchController.searchBar

    }
    
    @IBAction func close() {
        dismissViewControllerAnimated(true, completion: nil)
    }

}

extension SearchViewController: UISearchResultsUpdating {
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        print(searchController.searchBar.text)
    }
}