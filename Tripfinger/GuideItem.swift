import Foundation

public class GuideItem {
    
    public init() {}
    
    public var id: Int?
    public var slug: String?
    public var name: String?
    public var longitude: Double?
    public var latitude: Double?
    public var price: Double?
    public var type: Int?

    public var parent: GuideItem?
    public var description: String?
    public var openingHours: String?    
}
