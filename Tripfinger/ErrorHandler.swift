import Foundation

class ErrorHandler {
  
  class func error(message: String) {
    print(message)
  }
}

enum Error : ErrorType {
  case RuntimeError(String)
}