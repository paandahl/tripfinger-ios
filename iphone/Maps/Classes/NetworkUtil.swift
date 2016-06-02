import SystemConfiguration
import Alamofire
import SwiftyJSON

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

  
  class func getJsonFromUrl(var url: String, var parameters: [String: String] = Dictionary<String, String>(), method: Alamofire.Method = .GET, appendPass: Bool = true, success: (json: JSON) -> (), failure: () -> ()) -> Request {
    if appendPass {
      parameters["pass"] = "plJR86!!"
    }
    
    url = url.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!
    
    print("Fetching URL: \(url)")
    if parameters.count > 1 {
      print("Params: \(parameters)")
    }
    
    let request = alamoFireManager.request(method, url, parameters: parameters)

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
          dispatch_async(dispatch_get_main_queue(), failure)
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

  
  class func saveDataFromUrl(url: String, destinationPath: NSURL, var parameters: [String: String] = Dictionary<String, String>(), appendPass: Bool = true, dispatchGroup: dispatch_group_t? = nil, retryTimes: Int = 100, progressHandler: (Float -> ())? = nil, finishedHandler: (() -> ())? = nil) -> Request {
    if appendPass {
      parameters["pass"] = "plJR86!!"
    }

    let nsUrl = NSURL(string: url)!
    
    NSURL.deleteFile(destinationPath)
    let request = alamoFireManager.download(.GET, nsUrl, parameters: parameters) { temporaryUrl, response in
      return destinationPath
    }
    
    if let dispatchGroup = dispatchGroup {
      dispatch_group_enter(dispatchGroup)
      print("dispatch_group_enter: \(url)")
    }

    print("downloading file: \(url)")

    request.validate(statusCode: 200..<300)
      .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
        
        if let progressHandler = progressHandler {
          let progress = Float(totalBytesRead) / Float(totalBytesExpectedToRead)
          
          dispatch_async(dispatch_get_main_queue()) {
            progressHandler(progress)
          }
        }
      }
      .response {
        _, _, _, error in
        
        if let error = error {
          if retryTimes > 0 && error.code < 400 {
            if error.code == -999 {
              print("Download was cancelled")
            } else {
              print("Error was: \(error)")
              print("Status code was \(error.code), retrying download of: \(url)")
              saveDataFromUrl(url, destinationPath: destinationPath, parameters: parameters, appendPass: appendPass, dispatchGroup: dispatchGroup, retryTimes: retryTimes - 1, progressHandler: progressHandler, finishedHandler: finishedHandler)
            }
            if let dispatchGroup = dispatchGroup {
              dispatch_group_leave(dispatchGroup)
              print("dispatch_group_leave: \(url)")
            }
          } else {
            print(error)
            print("response: \(error.code)")
            try! { throw Error.RuntimeError("ERROR: Downloading file failed: \(url)") }()
          }
        } else {
          print("Wrote image to file: \(destinationPath)")
          if let dispatchGroup = dispatchGroup {
            dispatch_group_leave(dispatchGroup)
            print("dispatch_group_leave: \(url)")
          }
          if let finishedHandler = finishedHandler {
            finishedHandler()
          }
        }
    }
    return request
  }
}