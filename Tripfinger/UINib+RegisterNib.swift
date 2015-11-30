//
//  UINib+RegisterNib.swift
//  Tripfinger
//
//  Created by Preben Ludviksen on 11/10/15.
//  Copyright (c) 2015 Preben Ludviksen. All rights reserved.
//

import Foundation

extension UINib {
  
  class func registerNib(nibName: String, forTableView tableView: UITableView) {
    let cellNib = UINib(nibName: nibName, bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: nibName)
  }
  
  class func registerClass(cellClass: AnyClass, reuseIdentifier: String, forTableView tableView: UITableView) {
    tableView.registerClass(cellClass, forCellReuseIdentifier: reuseIdentifier)
  }
}