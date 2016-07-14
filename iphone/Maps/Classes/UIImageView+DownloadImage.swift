import Foundation

extension UIImageView {
  func loadImageWithUrl(url: String) throws -> NSURLSessionDataTask {
    if url == "" {
      throw Error.RuntimeError("URL was empty")
    }
    let nsUrl = NSURL(string: url)!
    return loadImageWithNSUrl(nsUrl)
  }
  
  func loadImageWithNSUrl(url: NSURL) -> NSURLSessionDataTask {
    print("Loading image from url: \(url.absoluteString)")

    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    indicator.startAnimating()
    self.addSubview(indicator)
    self.addConstraint(.CenterY, forView: indicator)
    self.addConstraint(.CenterX, forView: indicator)

    let session = NSURLSession.sharedSession()
    let downloadTask = session.dataTaskWithURL(url) {
      [weak self] data, response, error in
            
      if error == nil && data != nil,
        let image = UIImage(data: data!) {
          dispatch_async(dispatch_get_main_queue()) {
            if let strongSelf = self {
              strongSelf.image = image
              indicator.stopAnimating()
              indicator.hidden = true
            }
          }
      }
      else {
        assertionFailure("Could not load url: \(url.absoluteString)")
      }
    }
    
    downloadTask.resume()
    return downloadTask
  }
}
