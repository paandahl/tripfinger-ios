import Foundation

public class GuideItem {
    
    public init() {}
    
    public var id: Int!
    public var slug: String?
    public var name: String?
    public var price: Double?
    public var category: Int?

    public var parent: GuideItem?
    public var description: String?
    public var openingHours: String?
    
    public var images = Dictionary<String, String>()
    
    // temporary data to make things easier
    public var guideSections = [GuideText]()
    public var categoryDescriptions = [GuideText]()
}
