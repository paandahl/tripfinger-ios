import Foundation

class Attraction: GuideLocation {
    
    var coordinateX: Double?
    var coordinateY: Double?
    var title: String
    var image: UIImage?
    
    required init(title: String, coordinateX: Double?, coordinateY: Double?) {
        self.title = title
        if let uCoordinateX = coordinateX {
            if let uCoordinateY = coordinateY {
                self.coordinateX = uCoordinateX
                self.coordinateY = uCoordinateY
            }
        }
    }
    
    enum Types: Int {
        case EXPLORE_CITY = 210
        case ACTIVITY_HIKE_DAYTRIP = 220
        case TRANSPORTATION = 230
        case ACCOMODATION = 240
        case FOOD_OR_DRINK = 250
        case SHOPPING = 260
        case INFORMATION = 270

        var entityName: String {
            switch self {
            case .EXPLORE_CITY:
                return "Explore the city"
            case .ACTIVITY_HIKE_DAYTRIP:
                return "Activities"
            case .TRANSPORTATION:
                return "Transportation"
            case .ACCOMODATION:
                return "Accomodation"
            case .FOOD_OR_DRINK:
                return "Food and drinks"
            case .SHOPPING:
                return "Shopping"
            case .INFORMATION:
                return "Information"
            }
        }

        static let allValues = [EXPLORE_CITY, ACTIVITY_HIKE_DAYTRIP, TRANSPORTATION, ACCOMODATION,
            FOOD_OR_DRINK, SHOPPING, INFORMATION]
    }
    
}


//        title = "MIM - Musical Instruments Museum"
//        title = "Serres Royales De Laeken"
//        title = "Foret des Soignes"
//        title = "Royal Museum of the Armed Forces and of Military History"
//        title = "Notre Dame du Sablon"
//        title = "Museum of Natural Sciences"
//        title = "Bois de la Cambre"