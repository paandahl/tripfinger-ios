import Foundation

public class GuideItem {
    
    public init() {}
    
    public var id: String!
    public var slug: String?
    public var name: String?
    public var price: Double?
    public var category: Int?

    public var parent: GuideItem?
    public var description: String?
    public var openingHours: String?
    
    var images = [GuideItemImage]()
    
    // temporary data to make things easier
    public var guideSections = [GuideText]()
    public var categoryDescriptions = [GuideText]()
    
    class GuideItemImage {
        var url: String!
        var description: String!
    }
}
