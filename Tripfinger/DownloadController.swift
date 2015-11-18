//
//  DownloadController.swift
//  Tripfinger
//
//  Created by Preben Ludviksen on 17/11/15.
//  Copyright © 2015 Preben Ludviksen. All rights reserved.
//

import Foundation

class DownloadController: UIViewController {
  
  var downloadButton: UIButton!
  var progressView: UIProgressView!
  
  override func viewDidLoad() {
    view.backgroundColor = UIColor.whiteColor()
    edgesForExtendedLayout = UIRectEdge.None;
    
    downloadButton = UIButton.init(type: UIButtonType.System)
    downloadButton.setTitle("Download", forState: UIControlState.Normal)
    downloadButton.sizeToFit()
    downloadButton.addTarget(self, action: "downloadCity:", forControlEvents: UIControlEvents.TouchUpInside)
    view.addSubview(downloadButton)
    view.addConstraint(NSLayoutAttribute.CenterX, forView: downloadButton)
    view.addConstraints("V:[download]-100-|", forViews: ["download": downloadButton])
    
    progressView = UIProgressView(frame: CGRectMake(100, 100, 400, 40))
    progressView.progress = 0.0
    view.addSubview(progressView)
    view.addConstraint(NSLayoutAttribute.CenterX, forView: progressView)
    view.addConstraint(NSLayoutAttribute.CenterY, forView: progressView)
    view.addConstraints("V:[progress(40)]", forViews: ["progress": progressView])
    view.addConstraints("H:|-15-[progress]-15-|", forViews: ["progress": progressView])
  }
  
  func downloadCity(sender: UIButton) {
    DownloadService.downloadCity("region-belgium", cityId: "region-brussels") {
      progress in
      
      self.progressView.progress = progress
    }
  }
}
