import Foundation

class GuideItem {
    
    var id: Int?
    var slug: String?
    var name: String?
    var longitude: Double?
    var latitude: Double?
    var price: Double?
    var type: Int?

    var parent: GuideItem?
    var description: String?
    var openingHours: String?
    
}
