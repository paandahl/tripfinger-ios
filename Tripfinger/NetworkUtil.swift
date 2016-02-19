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
  
  class func saveDataFromUrl(url: String, destinationPath: NSURL, dispatchGroup: dispatch_group_t? = nil, retryTimes: Int = 100) {
    let nsUrl = encodeTripfingerImageUrl(url)
    let request = alamoFireManager.request(.GET, nsUrl)
    let backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    
    if let dispatchGroup = dispatchGroup {
      dispatch_group_enter(dispatchGroup)
      print("dispatch_group_enter: \(url)")
    }

    request.validate(statusCode: 200..<300).response(
      queue: backgroundQueue,
      responseSerializer: Request.dataResponseSerializer(),
      completionHandler: {
        response in
        
        print("downloading file: \(url)")
        if response.result.isSuccess {
          print("Writing image to file: \(destinationPath)")
          let result = response.data?.writeToURL(destinationPath, atomically: true)
          if !result! {
            try! { throw Error.RuntimeError("ERROR: Writing file failed: \(destinationPath)") }()
          }
          else {
            if let dispatchGroup = dispatchGroup {
              dispatch_group_leave(dispatchGroup)
              print("dispatch_group_leave: \(url)")
            }
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
  
  /*
   * Necessary because on server, some image urls are encoded properly, some are not
   */
  class func encodeTripfingerImageUrl(url: String) -> NSURL {
    let index = url.rangeOfString("/tripfinger-images/")!
    let decodedUrl = url.stringByRemovingPercentEncoding!
    let firstPart = decodedUrl.substringToIndex(index.endIndex)
    let lastPart = decodedUrl.substringFromIndex(index.endIndex)
    let encodedUrl = firstPart + lastPart.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet())!
    return NSURL(string: encodedUrl)!
  }
}