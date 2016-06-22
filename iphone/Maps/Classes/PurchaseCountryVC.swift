import Foundation
import StoreKit

class PurchaseCountryVC: FirstCountryDownloadView {
  
  let product: SKProduct
  
  init(country: Region, product: SKProduct, cancelHandler: () -> (), downloadHandler: () -> ()) {
    self.product = product
    super.init(country: country, cancelHandler: cancelHandler, downloadHandler: downloadHandler)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(downloadCountry),
                                                     name: PurchasesService.TFPurchaseNotification,
                                                     object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(paymentFailed),
                                                     name: PurchasesService.TFPurchaseFailedNotification,
                                                     object: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(cancel))
    image.image = UIImage(named: "img_search_no_maps");
    alertTitle.text = "This offline guide needs to be purchased before it can be downloaded";
    alertText.text = "With the offline guide you can view recommendations on the map, and take the guide with you on the road while travelling."
    let numberFormatter = NSNumberFormatter()
    numberFormatter.formatterBehavior = .Behavior10_4
    numberFormatter.numberStyle = .CurrencyStyle
    numberFormatter.locale = product.priceLocale
    let formattedPrice = numberFormatter.stringFromNumber(product.price)!
    confirmButton.setTitle("Buy (\(formattedPrice))", forState: .Normal)
    confirmButton.addTarget(self, action: #selector(purchaseCountry), forControlEvents: .TouchUpInside)
  }
  
  func purchaseCountry() {
    let payment = SKPayment(product: product)
    SKPaymentQueue.defaultQueue().addPayment(payment)
  }
  
  func paymentFailed() {
    alertTitle.text = "Payment failed"
    alertText.text = ""
  }
}