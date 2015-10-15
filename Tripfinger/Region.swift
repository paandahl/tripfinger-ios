import Foundation

public class Region: GuideListing {
    
    // radius
    var radius: Int?
    
    // polygons
    var polygonCoordinates: [Double]?
    
    func setType(type: Region.Types) {
        self.type = type.rawValue
    }

    public enum Types: Int {
        case CONTINENT = 110
        case WORLD_AREA = 120
        case COUNTRY = 130
        case REGION = 140
        case SUB_REGION = 150
        case CITY = 160
        case NEIGHBOURHOOD = 170
    }
}

