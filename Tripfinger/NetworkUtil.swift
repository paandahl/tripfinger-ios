import SystemConfiguration
import Alamofire

class NetworkUtil {
  
  class func connectedToNetwork() -> Bool {
    
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
    
    print("Fetching URL: \(url)")
    
    let request = Alamofire.request(method, url, parameters: parameters).validate(statusCode: 200..<300)
    let backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    
    request.response(
      queue: backgroundQueue,
      responseSerializer: Request.JSONResponseSerializer(options: .AllowFragments),
      completionHandler: {
        response in
        
        if response.result.isSuccess {
          let json = JSON(data: response.data!)
          success(json: json)
        }
        else {
          print("Failure fetching url: \(url)")
          print(response.result.error)
          if let failure = failure {
            dispatch_async(dispatch_get_main_queue(), failure)
          }
        }
    })
    
    return request
  }
  
  class func saveDataFromUrl(url: String, destinationPath: NSURL, retryTimes: Int = 3) {
    let nsUrl = NSURL(string: url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!
    let request = Alamofire.request(.GET, nsUrl)
    let backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    
    let exceptionHandler = {
      throw Error.RuntimeError("ERROR: Downloading file failed: \(url)")
    }

    request.response(
      queue: backgroundQueue,
      responseSerializer: Request.dataResponseSerializer(),
      completionHandler: {
        response in
        
        print("downloading file: \(url)")
        if response.result.isSuccess {
          print("Writing image to file: \(destinationPath)")
          let result = response.data?.writeToURL(destinationPath, atomically: true)
          if !result! {
            print("ERROR: Writing file failed")
          }
        }
        else {
          if retryTimes > 0 {
            print("retrying downlaod of: \(url)")
            NetworkUtil.saveDataFromUrl(url, destinationPath: destinationPath, retryTimes: retryTimes - 1)
          }
          else {
            print(response.description)
            print(response)
            print("response: \(response.response?.statusCode)")
            try! exceptionHandler()
          }
        }
    })
  }
}