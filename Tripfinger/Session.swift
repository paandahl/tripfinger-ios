//
//  Session.swift
//  Tripfinger
//
//  Created by Preben Ludviksen on 08/10/15.
//  Copyright (c) 2015 Preben Ludviksen. All rights reserved.
//

import Foundation

public class Session {
    
    public init() {}
    
    public var currentRegion: Region?
    public var currentAttractions = [Attraction]()
    
    public func loadAttractions(handler: () -> ()) {
        ContentService.getAttractionsForRegion(self.currentRegion!) {
            attractions in
            
            self.currentAttractions = attractions
            handler()
        }

    }
}