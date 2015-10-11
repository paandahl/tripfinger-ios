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
        
        static let allValues = [EXPLORE_CITY, ACTIVITY_HIKE_DAYTRIP, TRANSPORTATION, ACCOMODATION,
            FOOD_OR_DRINK, SHOPPING, INFORMATION]
    }
    
    class func getNameForType(type: Types) -> String {
        switch type {
        case Types.EXPLORE_CITY:
            return "Explore the city"
        case Types.ACTIVITY_HIKE_DAYTRIP:
            return "Activities"
        case Types.TRANSPORTATION:
            return "Transportation"
        case Types.ACCOMODATION:
            return "Accomodation"
        case Types.FOOD_OR_DRINK:
            return "Food and drinks"
        case Types.SHOPPING:
            return "Shopping"
        case Types.INFORMATION:
            return "Information"
        }
    }
}


//        title = "MIM - Musical Instruments Museum"
//        title = "Serres Royales De Laeken"
//        title = "Foret des Soignes"
//        title = "Royal Museum of the Armed Forces and of Military History"
//        title = "Notre Dame du Sablon"
//        title = "Museum of Natural Sciences"
//        title = "Bois de la Cambre"