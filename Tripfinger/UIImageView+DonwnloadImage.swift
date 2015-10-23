//
//  UIImageView+DonwnloadImage.swift
//  Tripfinger
//
//  Created by Preben Ludviksen on 17/10/15.
//  Copyright (c) 2015 Preben Ludviksen. All rights reserved.
//

import Foundation

extension UIImageView {
    func loadImageWithUrl(url: String) -> NSURLSessionDataTask {
        let nsUrl = NSURL(string: url)!
        return loadImageWithNSUrl(nsUrl)
    }
    
    func loadImageWithNSUrl(url: NSURL) -> NSURLSessionDataTask {
        let session = NSURLSession.sharedSession()
        let downloadTask = session.dataTaskWithURL(url) {
            [weak self] data, response, error in
            
            if error == nil && data != nil,
                let image = UIImage(data: data!) {
                    dispatch_async(dispatch_get_main_queue()) {
                        if let strongSelf = self {
                            strongSelf.image = image
                        }
                    }
            }
        }
        
        downloadTask.resume()
        return downloadTask
    }
}
