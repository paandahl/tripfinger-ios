import Foundation
import RealmSwift

class DownloadController: UIViewController {
  
  var mapsObject: SKTMapsObject!
  var country: Region!
  var countryPackage: SKTPackage!
  var region: Region!
  var regionPackage: SKTPackage!
  var onlyMap = false
  var dataHolder: Region!
  
  var nameLabel: UILabel!
  var deleteButton: UIButton!
  var downloadButton: UIButton!
  var progressView: UIProgressView!
  
  override func viewDidLoad() {
    view.backgroundColor = UIColor.whiteColor()
    edgesForExtendedLayout = UIRectEdge.None;
    let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "close")
    navigationItem.leftBarButtonItem = cancelButton
    
    let countryDownloaded = DownloadService.isRegionDownloaded(mapsObject, region: country)
    let cityDownloaded = DownloadService.isRegionDownloaded(mapsObject, region: region)

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
        nameLabel.text = "Country \(country.getName()) is downloaded."
        nameLabel.sizeToFit()
        dataHolder = country
        
        if region.getId() != country.getId() {
          downloadButton.enabled = false
          deleteButton.enabled = false
        }
      }
      else {
        nameLabel.text = "City \(region.getName()) is downloaded."
        nameLabel.sizeToFit()
        dataHolder = region
      }
      downloadButton.addTarget(self, action: "redownloadRegion", forControlEvents: UIControlEvents.TouchUpInside)
      downloadButton.setTitle("Re-download", forState: UIControlState.Normal)
      deleteButton.hidden = false
    }
    else {
      
      nameLabel.text = "Download \(region.getName()):"
      
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
    if region.getId() == country.getId() {
      let downloadedCities = OfflineService.getRegionsWithParent(region.getId())
      for city in downloadedCities {
        DownloadService.deleteMapForRegion(city.getId())
        OfflineService.deleteRegionWithId(city.getId())
      }
      
      DownloadService.downloadCountry(country.getId(), package: countryPackage, onlyMap: onlyMap, progressHandler: {
        progress in
        
        self.progressView.progress = progress
        
        }, finishedHandler: {
          
          self.deleteButton.hidden = false
      })
    }
    else {
      DownloadService.downloadCity(country.getId(), cityId: region.getId(), package: regionPackage, onlyMap: onlyMap, progressHandler: {
        progress in
        
        self.progressView.progress = progress
        
        }, finishedHandler: {
          
          self.deleteButton.hidden = false
      })
      
    }
    downloadButton.enabled = false
  }
  
  func deleteRegion() {
    DownloadService.deleteRegion(dataHolder.getId(), countryId: country.getId())
    nameLabel.text = "Deleted \(dataHolder.getName())."
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
