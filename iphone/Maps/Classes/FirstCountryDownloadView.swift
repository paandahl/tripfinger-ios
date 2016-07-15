import Foundation

class FirstCountryDownloadView: UIViewController {
  
  @IBOutlet weak var image: UIImageView!
  @IBOutlet weak var alertTitle: UILabel!
  @IBOutlet weak var alertText: UILabel!
  @IBOutlet weak var confirmButton: UIButton!
 
  let country: Region
  let downloadHandler: (() -> ()) -> ()
  let cancelHandler: () -> ()

  init(country: Region, cancelHandler: () -> (), downloadHandler: (() -> ()) -> ()) {
    self.country = country
    self.downloadHandler = downloadHandler
    self.cancelHandler = cancelHandler
    super.init(nibName: "FirstCountryDownloadView", bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {    
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(cancel))
    image.image = UIImage(named: "img_search_no_maps");
    alertTitle.text = "Ready to download your first guide";
    alertText.text = "Your first country is free of charge. Are you sure you want \(country.getName()) to be your free country? Your choice is final."
    confirmButton.addTarget(self, action: #selector(downloadCountry), forControlEvents: .TouchUpInside)
  }
  
  func downloadCountry() {
    showLoadingHud()
    print("relaying to downloadHandler")
    downloadHandler {
      self.hideHuds()
    }
  }
  
  func cancel() {
    TripfingerAppDelegate.navigationController.dismissViewControllerAnimated(true, completion: nil)
    cancelHandler()
  }
}