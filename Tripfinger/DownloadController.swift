import Foundation
import RealmSwift

class DownloadController: UIViewController {
  
  var countryName: String!
  var countryId: String!
  var regionName: String!
  var regionId: String!
  var dataHolderName: String!
  var dataHolderId: String!
  
  var nameLabel: UILabel!
  var deleteButton: UIButton!
  var downloadButton: UIButton!
  var progressView: UIProgressView!
  
  override func viewDidLoad() {
    view.backgroundColor = UIColor.whiteColor()
    edgesForExtendedLayout = UIRectEdge.None;
    let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "close")
    navigationItem.leftBarButtonItem = cancelButton
    
    let countryDownloaded = DownloadService.isRegionDownloaded(countryId)
    let cityDownloaded = DownloadService.isRegionDownloaded(regionId)

    nameLabel = UILabel()
    view.addSubview(nameLabel)
    view.addConstraint(.CenterX, forView: nameLabel)
    downloadButton = UIButton(type: .System)
    view.addSubview(downloadButton)
    view.addConstraint(.CenterX, forView: downloadButton)
    progressView = UIProgressView(frame: CGRectMake(100, 100, 400, 40))
    progressView.progress = 0.0
    view.addSubview(progressView)
    view.addConstraint(.CenterX, forView: progressView)
    view.addConstraint(.CenterY, forView: progressView)
    deleteButton = UIButton(type: .System)
    deleteButton.setTitle("Delete", forState: .Normal)
    deleteButton.sizeToFit()
    deleteButton.addTarget(self, action: "deleteRegion", forControlEvents: UIControlEvents.TouchUpInside)
    view.addSubview(deleteButton)
    view.addConstraint(.CenterX, forView: deleteButton)
    view.addConstraints("V:[download]-10-[delete]-70-|", forViews: ["download": downloadButton, "delete": deleteButton])

    view.addConstraints("V:[label]-40-[progress(40)]", forViews: ["progress": progressView, "label": nameLabel])
    view.addConstraints("H:|-15-[progress]-15-|", forViews: ["progress": progressView])

    if cityDownloaded || countryDownloaded {

      if countryDownloaded {
        nameLabel.text = "Country \(countryName) is downloaded."
        nameLabel.sizeToFit()
        dataHolderId = countryId
        dataHolderName = countryName
        
        if regionId != countryId {
          downloadButton.enabled = false
          deleteButton.enabled = false
        }
      }
      else {
        nameLabel.text = "City \(regionName) is downloaded."
        nameLabel.sizeToFit()
        dataHolderId = regionId
        dataHolderName = regionName
      }
      downloadButton.addTarget(self, action: "redownloadRegion", forControlEvents: UIControlEvents.TouchUpInside)
      downloadButton.setTitle("Re-download", forState: UIControlState.Normal)
      deleteButton.hidden = false
    }
    else {
      
      nameLabel.text = "Download \(regionName):"
      
      deleteButton.hidden = true
      downloadButton.setTitle("Download", forState: UIControlState.Normal)
      downloadButton.addTarget(self, action: "downloadRegion", forControlEvents: UIControlEvents.TouchUpInside)
    }
    nameLabel.sizeToFit()
    downloadButton.sizeToFit()
  }
  
  func close() {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func downloadRegion() {
    if regionId == countryId {
      let downloadedCities = OfflineService.getRegionsWithParent(regionId)
      for city in downloadedCities {
        DownloadService.deleteMapForRegion(city.getId())
        OfflineService.deleteRegionWithId(city.getId())
      }
      
      DownloadService.downloadCountry(countryId, progressHandler: {
        progress in
        
        self.progressView.progress = progress
        
        }, finishedHandler: {
          
          self.deleteButton.hidden = false
      })
    }
    else {
      DownloadService.downloadCity(countryId, cityId: regionId, progressHandler: {
        progress in
        
        self.progressView.progress = progress
        
        }, finishedHandler: {
          
          self.deleteButton.hidden = false
      })
      
    }
    downloadButton.enabled = false
  }
  
  func deleteRegion() {
    DownloadService.deleteRegion(dataHolderId, countryId: countryId)
    nameLabel.text = "Deleted \(dataHolderName)."
    deleteButton.hidden = true
  }
  
  func redownloadRegion() {
    print("RE-downloading")
    if !nameLabel.text!.hasPrefix("Deleted") {
      deleteRegion()
    }
    downloadRegion()
  }
}
