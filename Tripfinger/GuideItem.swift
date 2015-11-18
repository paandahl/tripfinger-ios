import Foundation
import RealmSwift

public class GuideItem: Object {
    
    public required init() {}
    
    public var id: String!
    public var slug: String?
    public var name: String?
    public var price: Double?
    public var category: Int?

    public var parent: GuideItem?
    public var content: String?
    public var openingHours: String?
    
    var images = [GuideItemImage]()
    
    // temporary data to make things easier
    public var guideSections = [GuideText]()
    public var categoryDescriptions = [GuideText]()    
}
