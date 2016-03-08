import SystemConfiguration
import Alamofire

class NetworkUtil {

  static var alamoFireManager: Alamofire.Manager!
  static var simulateOffline = false
  
  class func connectedToNetwork() -> Bool {
    
    if simulateOffline {
      return false
    }
    
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
      SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
    }) else {
      return false
    }
    
    var flags : SCNetworkReachabilityFlags = []
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
      return false
    }
    
    let isReachable = flags.contains(.Reachable)
    let needsConnection = flags.contains(.ConnectionRequired)
    return (isReachable && !needsConnection)
  }

  
  class func getJsonFromUrl(var url: String, var parameters: [String: String] = Dictionary<String, String>(), method: Alamofire.Method = .GET, appendPass: Bool = true, success: (json: JSON) -> (), failure: (() -> ())? = nil) -> Request {
    if appendPass {
      parameters["pass"] = "plJR86!!"
    }
    
    url = url.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!
    
    let thrower = {
      throw Error.DownloadError("Failure fetching url: \(url)")
    }
    print("Fetching URL: \(url)")
    if parameters.count > 1 {
      print("Params: \(parameters)")
    }
    
    let request = Alamofire.request(method, url, parameters: parameters).validate(statusCode: 200..<300)
    let backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    
    request.validate(statusCode: 200..<300).response(
      queue: backgroundQueue,
      responseSerializer: Request.JSONResponseSerializer(options: .AllowFragments),
      completionHandler: {
        response in
        
        if response.result.isSuccess {
          let json = JSON(data: response.data!)
          success(json: json)
        }
        else if response.result.error?.code != -999 {
          print(response.result.error)
          if let failure = failure {
            dispatch_async(dispatch_get_main_queue(), failure)
          }
          else {
            try! thrower()
          }
        }
    })
    
    return request
  }
  
//  class func downloadFile(url: String, destinationPath: NSURL, progressHandler: (Float -> ())?, finishedHandler: (() -> ())?) {
//    Alamofire.request(.GET, url)
//      .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
//        
//        if let progressHandler = progressHandler {
//          let progress = Float(totalBytesRead) / Float(totalBytesExpectedToRead)
//          
//          dispatch_async(dispatch_get_main_queue()) {
//            progressHandler(progress)
//          }
//        }
//      }
//      .responseData { response in
//        
//        print("Writing file to disk: \(destinationPath.absoluteString)")
//        if response.result.isSuccess {
//          let result = response.data?.writeToURL(destinationPath, atomically: true)
//          if !result! {
//            print("ERROR: Writing file failed")
//          }
//          if let finishedHandler = finishedHandler {
//            finishedHandler()
//          }
//        }
//        else {
//          print("ERROR: Downloading file failed")
//        }
//    }
//  }

  
  class func saveDataFromUrl(url: String, destinationPath: NSURL, dispatchGroup: dispatch_group_t? = nil, retryTimes: Int = 100, progressHandler: (Float -> ())? = nil) {
    let nsUrl = NSURL(string: url)!
    let request = alamoFireManager.request(.GET, nsUrl)
    let backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    
    if let dispatchGroup = dispatchGroup {
      dispatch_group_enter(dispatchGroup)
      print("dispatch_group_enter: \(url)")
    }

    request.validate(statusCode: 200..<300)
      .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
        
        if let progressHandler = progressHandler {
          let progress = Float(totalBytesRead) / Float(totalBytesExpectedToRead)
          
          dispatch_async(dispatch_get_main_queue()) {
            progressHandler(progress)
          }
        }
      }
      .response(
      queue: backgroundQueue,
      responseSerializer: Request.dataResponseSerializer(),
      completionHandler: {
        response in
        
        print("downloading file: \(url)")
        if response.result.isSuccess {
          print("Writing image to file: \(destinationPath)")
          try! response.data!.writeToURL(destinationPath, options: NSDataWritingOptions.AtomicWrite)
          if let dispatchGroup = dispatchGroup {
            dispatch_group_leave(dispatchGroup)
            print("dispatch_group_leave: \(url)")
          }
        }
        else {
          if retryTimes > 0 && response.response?.statusCode < 400 {
            print("retrying download of: \(url)")
            saveDataFromUrl(url, destinationPath: destinationPath, dispatchGroup: dispatchGroup, retryTimes: retryTimes - 1)
            if let dispatchGroup = dispatchGroup {
              dispatch_group_leave(dispatchGroup)
              print("dispatch_group_leave: \(url)")
            }
          }
          else {
            print(response.description)
            print(response)
            print("response: \(response.response?.statusCode)")
            try! { throw Error.RuntimeError("ERROR: Downloading file failed: \(url)") }()
          }
        }
    })
  }
}