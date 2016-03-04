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
    return (poi.category == 2392 && zoomLevel < 12) || (poi.category == 2393 && zoomLevel < 15) || String(poi.category).hasPrefix("1")
  }
  
  private func styleAnnotation(annotation: SKAnnotation) {
    
    let selected = (selectedAnnotation != nil && selectedAnnotation!.location.latitude == annotation.location.latitude
      && selectedAnnotation!.location.longitude == annotation.location.longitude)
    let poi = annotationGroups[annotation]![0]
    let liked = poi.notes != nil && poi.notes!.likedState == GuideListingNotes.LikedState.LIKED
    
    let annotationIcon: String
    switch poi.getAttractionCategory() {
    case Attraction.Category.ATTRACTIONS:
      switch poi.getAttractionSubCategory() {

      case Attraction.SubCategory.SIGHTS_AND_LANDMARKS:
        annotationIcon = "attraction"
      case Attraction.SubCategory.PARK:
        annotationIcon = "park"
      case Attraction.SubCategory.MUSEUM:
        annotationIcon = "museum"
      case Attraction.SubCategory.SPORTS:
        annotationIcon = "sports"
      case Attraction.SubCategory.THEATER_AND_CONCERTS:
        annotationIcon = "theatre"
      default:
        print("displaying poi from category: \(poi.getAttractionSubCategory().rawValue)")
        annotationIcon = "attraction"
      }
      
    case Attraction.Category.FOOD_OR_DRINK:
      annotationIcon = "restaurant"
    case Attraction.Category.INFORMATION:
      annotationIcon = "information"
    case Attraction.Category.SHOPPING:
      annotationIcon = "shop"
    case Attraction.Category.ACCOMODATION:
      annotationIcon = "hotel"
      
    case Attraction.Category.TRANSPORTATION:
      switch poi.getAttractionSubCategory() {
      case Attraction.SubCategory.AIRPORT:
        annotationIcon = "airport"
      case Attraction.SubCategory.TRAIN_STATION:
        annotationIcon = "train"
      case Attraction.SubCategory.BUS_STATION:
        fallthrough
      case Attraction.SubCategory.BUS_STOP:
        annotationIcon = "bus"
      case Attraction.SubCategory.FERRY_TERMINAL:
        fallthrough
      case Attraction.SubCategory.FERRY_STOP:
        annotationIcon = "ferry"
      case Attraction.SubCategory.METRO_STATION:
        annotationIcon = "metro"
      case Attraction.SubCategory.METRO_ENTRANCE:
        annotationIcon = "metro_entrance"
      case Attraction.SubCategory.TRAM_STOP:
        annotationIcon = "tram"
      case Attraction.SubCategory.CAR_RENTAL:
        annotationIcon = "metro_entrance"
      case Attraction.SubCategory.BICYCLE_RENTAL:
        fallthrough
      case Attraction.SubCategory.MOTORBIKE_RENTAL:
        annotationIcon = "bicycle"
      default:
        fatalError("Unrecognized subCategory for transportation: \(poi.getAttractionSubCategory().rawValue)")
      }
    }

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