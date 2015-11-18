//
//  SearchResult.swift
//  Tripfinger
//
//  Created by Preben Ludviksen on 21/10/15.
//  Copyright © 2015 Preben Ludviksen. All rights reserved.
//

import Foundation

class SearchResult {
  
  var name: String!
  var city: String!
  var latitude: Double!
  var longitude: Double!
  var resultType: ResultType!
  
  enum ResultType: Int {
    case Street = 1
  }
  
}