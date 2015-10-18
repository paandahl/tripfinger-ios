
import Foundation

class DataManager {
    
    class func getAttractionDateFromFileWithSuccess(success: ((data: NSData) -> Void)) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let filePath = NSBundle.mainBundle().pathForResource("/Data/Data", ofType:"json")
            
            var readError:NSError?
            do {
                let data = try NSData(contentsOfFile:filePath!,
                    options: NSDataReadingOptions.DataReadingUncached)
                    success(data: data)
            } catch let error as NSError {
                readError = error
            } catch {
                fatalError()
            }
        })
    }
}
