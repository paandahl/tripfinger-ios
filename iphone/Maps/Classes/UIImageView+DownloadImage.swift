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
      else {
         try! { throw Error.RuntimeError("Could not load url: \(url.absoluteString)") }()
      }
    }
    
    downloadTask.resume()
    return downloadTask
  }
  
  class func sizeAspectFit(aspectRatio: CGSize, var boundingSize: CGSize) -> CGSize {
    let mW = boundingSize.width / aspectRatio.width;
    let mH = boundingSize.height / aspectRatio.height;
    if mH < mW {
      boundingSize.width = mH * aspectRatio.width;
    } else if mW < mH {
      boundingSize.height = mW * aspectRatio.height;
    }
    return boundingSize;
  }
  
  class func sizeAspectFill(aspectRatio: CGSize, var minimumSize: CGSize) -> CGSize {
    let mW = minimumSize.width / aspectRatio.width;
    let mH = minimumSize.height / aspectRatio.height;
    if mH > mW {
      minimumSize.width = mH * aspectRatio.width;
    } else if mW > mH {
      minimumSize.height = mW * aspectRatio.height;
    }
    return minimumSize;
  }
}
