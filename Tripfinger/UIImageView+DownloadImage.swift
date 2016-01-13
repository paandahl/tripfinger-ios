import Foundation

extension UIImageView {
  func loadImageWithUrl(url: String) throws -> NSURLSessionDataTask {
    if url == "" {
      throw Error.RuntimeError("URL was empty")
    }
    let nsUrl = NSURL(string: url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!
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
