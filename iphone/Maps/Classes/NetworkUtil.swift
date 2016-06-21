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

  
  class func getJsonFromUrl(url: String, parameters: [String: String]? = nil, method: Alamofire.Method = .GET, appendParams: Bool = true, failure: () -> (), success: (json: JSON) -> ()) -> Request {
    var parameters = parameters ?? Dictionary<String, String>()
    if appendParams {
      parameters["fetchType"] = getFetchType()
      parameters["pass"] = "plJR86!!"
    }
    
    let escapedUrl = url.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!
    
    print("Fetching URL: \(escapedUrl)")
    if parameters.count > 1 {
      print("Params: \(parameters)")
    }
    
    let request = alamoFireManager.request(method, escapedUrl, parameters: parameters)

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
  
  class func getJsonFromPost(url: String, body: String, appendPass: Bool = true, success: (json: JSON) -> (), failure: (() -> ())? = nil) {
    
    let fullUrl = appendPass ? url + "?pass=plJR86!!" : url
    print("Fetching POST URL: \(fullUrl)")
    let nsUrl = NSURL(string: fullUrl)!
    let request = NSMutableURLRequest(URL: nsUrl)
    request.HTTPMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
    
    Alamofire.request(request).validate(statusCode: 200..<300).responseJSON {
      response in
      
      if response.result.isSuccess {
        let json = JSON(data: response.data!)
        success(json: json)
      }
      else {
        print("Failure fetching url: \(fullUrl)")
        print(response.result.error)
        if let failure = failure {
          dispatch_async(dispatch_get_main_queue(), failure)
        }
      }
    }
  }

  class func saveDataFromUrl(url: String, destinationPath: NSURL, parameters: [String: String]? = nil, appendParams: Bool = true, dispatchGroup: dispatch_group_t? = nil, retryTimes: Int = 100, method: Alamofire.Method = .GET, body: String? = nil, progressHandler: (Float -> ())? = nil, finishedHandler: (() -> ())? = nil) -> Request {
    var fullUrl = url
    var fullParameters = parameters ?? Dictionary<String, String>()
    if appendParams && method == .POST {
      fullUrl += "?pass=plJR86!!&fetchType=" + getFetchType()
    } else if appendParams {
      fullParameters["pass"] = "plJR86!!"
      fullParameters["fetchType"] = getFetchType()
    }

    let nsUrl = NSURL(string: fullUrl)!
    
    NSURL.deleteFile(destinationPath)
    let request = alamoFireManager.download(method, nsUrl, parameters: fullParameters) { temporaryUrl, response in
      return destinationPath
    }
    if let body = body {
      fullParameters["body"] = body
    }

    
    if let dispatchGroup = dispatchGroup {
      dispatch_group_enter(dispatchGroup)
      print("dispatch_group_enter: \(fullUrl)")
    }

    print("downloading file: \(fullUrl)")

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
              saveDataFromUrl(url, destinationPath: destinationPath, parameters: parameters, appendParams: appendParams, dispatchGroup: dispatchGroup, retryTimes: retryTimes - 1, progressHandler: progressHandler, finishedHandler: finishedHandler)
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
  
  private class func getFetchType() -> String {
    switch TripfingerAppDelegate.mode {
    case .RELEASE:
      return "ONLY_PUBLISHED"
    case .BETA:
      return "STAGED_OR_PUBLISHED"
    case .DRAFT:
      fallthrough
    case .TEST:
      return "NEWEST"
    }
  }
}