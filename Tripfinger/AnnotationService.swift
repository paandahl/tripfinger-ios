import Foundation
import RealmSwift

class AnnotationService {
  
  private let groupingDistance: CGFloat = 10
  private var selectedAnnotation: SKAnnotation?
  private var annotationGroups = [SKAnnotation: [SimplePOI]]()
  
  func getAnnotations(pois: List<SimplePOI>, mapView: SKMapView, selectedPoi: SimplePOI?) -> [SKAnnotation] {
    
    selectedAnnotation = nil
    let zoomLevel = Int(mapView.visibleRegion.zoomLevel)
    print("creating annotations for \(pois.count) pois")
    
    var annotations = [SKAnnotation]()
    var identifier: Int32 = 0
    for poi in pois {
      let selected = (selectedPoi != nil && poi.name == selectedPoi!.name
        && poi.latitude == selectedPoi!.latitude && poi.longitude == selectedPoi!.longitude)
      if !selected && isPoiHidden(poi, zoomLevel: zoomLevel) {
        identifier += 1
        continue
      }
      // see if an annotation is already added too close by
      var wasGrouped = false
      for annotation in annotations {
        let annotationPoint = mapView.pointForCoordinate(annotation.location)
        let poiCoord = CLLocationCoordinate2DMake(poi.latitude, poi.longitude)
        let poiPoint = mapView.pointForCoordinate(poiCoord)
        if abs(annotationPoint.x - poiPoint.x) < groupingDistance && abs(annotationPoint.y - poiPoint.y) < groupingDistance {
          if let notes = poi.notes where notes.likedState == GuideListingNotes.LikedState.LIKED {
            annotationGroups[annotation]!.insert(poi, atIndex: 0)
            print("LIKED")
          } else {
            annotationGroups[annotation]!.append(poi)
          }
          wasGrouped = true
          if selected {
            selectedAnnotation = annotation
          }
          styleAnnotation(annotation)
          break
        }
      }
      if wasGrouped {
        continue
      }
      
      let annotation = SKAnnotation()
      if selected {
        selectedAnnotation = annotation
      }
      annotation.identifier = identifier

      annotationGroups[annotation] = [poi]
      styleAnnotation(annotation)
      annotation.location = CLLocationCoordinate2DMake(poi.latitude, poi.longitude)
      annotations.append(annotation)
      identifier += 1
    }
    print("\(pois.count) POIs became \(annotations.count) annotations.")
    return annotations
  }

  func isPoiHidden(poi: SimplePOI, zoomLevel: Int) -> Bool {
    
    // regions
    if String(poi.category).hasPrefix("1") {
      return true
    }

    let visibilityLevel: Int
    switch poi.getListingCategory() {
    case Listing.Category.TRANSPORTATION:
      switch poi.getListingSubCategory() {
      case Listing.SubCategory.METRO_STATION:
        visibilityLevel = 12
      case Listing.SubCategory.METRO_ENTRANCE:
        visibilityLevel = 15
      default:
        visibilityLevel = 5
      }
      
    case Listing.Category.SHOPPING:
//      switch poi.getListingSubCategory() {
//        case Listing.SubCategory.
//        
//      }
      visibilityLevel = 12
      
    default:
      visibilityLevel = 5
    }
    
    return zoomLevel < visibilityLevel
  }
  
  private func styleAnnotation(annotation: SKAnnotation) {
    
    let selected = (selectedAnnotation != nil && selectedAnnotation!.location.latitude == annotation.location.latitude
      && selectedAnnotation!.location.longitude == annotation.location.longitude)
    let poi = annotationGroups[annotation]![0]
    let liked = poi.notes != nil && poi.notes!.likedState == GuideListingNotes.LikedState.LIKED
    
    let annotationIcon: String
    switch poi.getListingCategory() {
    case Listing.Category.ATTRACTIONS:
      switch poi.getListingSubCategory() {

      case Listing.SubCategory.SIGHTS_AND_LANDMARKS:
        annotationIcon = "attraction"
      case Listing.SubCategory.PARK:
        annotationIcon = "park"
      case Listing.SubCategory.MUSEUM:
        annotationIcon = "museum"
      case Listing.SubCategory.SPORTS:
        annotationIcon = "sports"
      case Listing.SubCategory.THEATER_AND_CONCERTS:
        annotationIcon = "theatre"
      default:
        print("displaying poi from category: \(poi.getListingSubCategory().rawValue)")
        annotationIcon = "attraction"
      }
      
    case Listing.Category.FOOD_OR_DRINK:
      annotationIcon = "restaurant"
    case Listing.Category.INFORMATION:
      annotationIcon = "information"
    case Listing.Category.SHOPPING:
      annotationIcon = "shop"
    case Listing.Category.ACCOMODATION:
      annotationIcon = "hotel"
      
    case Listing.Category.TRANSPORTATION:
      switch poi.getListingSubCategory() {
      case Listing.SubCategory.AIRPORT:
        annotationIcon = "airport"
      case Listing.SubCategory.TRAIN_STATION:
        annotationIcon = "train"
      case Listing.SubCategory.BUS_STATION:
        fallthrough
      case Listing.SubCategory.BUS_STOP:
        annotationIcon = "bus"
      case Listing.SubCategory.FERRY_TERMINAL:
        fallthrough
      case Listing.SubCategory.FERRY_STOP:
        annotationIcon = "ferry"
      case Listing.SubCategory.METRO_STATION:
        annotationIcon = "metro"
      case Listing.SubCategory.METRO_ENTRANCE:
        annotationIcon = "metro_entrance"
      case Listing.SubCategory.TRAM_STOP:
        annotationIcon = "tram"
      case Listing.SubCategory.CAR_RENTAL:
        annotationIcon = "metro_entrance"
      case Listing.SubCategory.BICYCLE_RENTAL:
        fallthrough
      case Listing.SubCategory.MOTORBIKE_RENTAL:
        annotationIcon = "bicycle"
      default:
        fatalError("Unrecognized subCategory for transportation: \(poi.getListingSubCategory().rawValue)")
      }
    }
    print(annotationIcon)

    annotation.annotationView = getAnnotationViewWithIcon(annotationIcon, selected: selected, liked: liked)
  }
  
  private func getAnnotationViewWithIcon(named: String, selected: Bool, liked: Bool) -> SKAnnotationView {
    let annotationView = UIView(frame: CGRectMake(0, 0, 14, 14))
    annotationView.layer.cornerRadius = 7
    let imageView = UIImageView(frame: CGRectMake(1, 1, 12, 12))
    imageView.image = UIImage(named: named)
    annotationView.addSubview(imageView)
    let reuseIdentifier: String
    if selected {
      annotationView.backgroundColor = UIColor.greenColor()
      reuseIdentifier = "\(named)-selected"
    } else if liked {
      annotationView.backgroundColor = UIColor.redColor()
      reuseIdentifier = "\(named)-liked"
    } else {
      annotationView.backgroundColor = UIColor.whiteColor()
      reuseIdentifier = named
    }
    return SKAnnotationView(view: annotationView, reuseIdentifier: reuseIdentifier)
  }
  
  func annotationSelected(annotation: SKAnnotation) -> [SKAnnotation] {
    selectedAnnotation = annotation
    styleAnnotation(annotation)
    return [annotation]
  }
  
  func selectedPois() -> [SimplePOI] {
    if let selectedAnnotation = selectedAnnotation {
      return annotationGroups[selectedAnnotation]!
    } else {
      return []
    }
  }
  
  func poiUnselected() -> [SKAnnotation] {
    if let selectedAnnotation = selectedAnnotation {
      self.selectedAnnotation = nil
      styleAnnotation(selectedAnnotation)
      return [selectedAnnotation]
    } else {
      return []
    }
  }
}