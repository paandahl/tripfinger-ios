import Foundation
import RealmSwift

class AnnotationService {
  
  private let groupingDistance: CGFloat = 10
  private var selectedAnnotation: SKAnnotation?
  private var annotationGroups = [SKAnnotation: [SimplePOI]]()
  
  func getAnnotations(pois: List<SimplePOI>, mapView: SKMapView) -> [SKAnnotation] {
    
    let zoomLevel = Int(mapView.visibleRegion.zoomLevel)
    print("creating annotations for \(pois.count) pois")
    
    var annotations = [SKAnnotation]()
    var identifier: Int32 = 0
    var likedAttractions = 0
    for poi in pois {
      let selected = isPoiSelected(poi)
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
          annotation.annotationView = nil
          annotation.annotationType = SKAnnotationType.Purple
          annotationGroups[annotation]!.append(poi)
          wasGrouped = true
          break
        }
      }
      if wasGrouped {
        continue
      }
      
      let annotation = SKAnnotation()
      annotation.identifier = identifier
      
      if poi.category == 2392 {
        annotation.annotationView = getAnnotationViewWithIcon("subway-m", selected: selected)
      } else if poi.category == 2393 {
        annotation.annotationView = getAnnotationViewWithIcon("subway-entrance-m", selected: selected)
      } else if String(poi.category).hasPrefix("26") {
        annotation.annotationView = getAnnotationViewWithIcon("shop-m", selected: selected)
      } else {
        if selected {
          annotation.annotationType = SKAnnotationType.Green
          
        } else if let notes = poi.notes where notes.likedState == GuideListingNotes.LikedState.LIKED {
          annotation.annotationType = SKAnnotationType.Red
          print("was liked: \(poi.name)")
          likedAttractions += 1
          
        } else {
          annotation.annotationType = SKAnnotationType.Blue
        }
      }
      annotation.location = CLLocationCoordinate2DMake(poi.latitude, poi.longitude)
      annotations.append(annotation)
      if selected {
        selectedAnnotation = annotation
      }
      annotationGroups[annotation] = [poi]
      identifier += 1
    }
    print("There were \(likedAttractions) liked attractions.")
    print("\(pois.count) POIs became \(annotations.count) annotations.")
    return annotations
  }
  
  func isPoiSelected(poi: SimplePOI) -> Bool {
    if let selectedAnnotation = selectedAnnotation {
      return annotationGroups[selectedAnnotation]!.contains({ $0.latitude == poi.latitude && $0.longitude == poi.longitude })
    } else {
      return false
    }
  }

  func isPoiHidden(poi: SimplePOI, zoomLevel: Int) -> Bool {
    return (poi.category == 2392 && zoomLevel < 12) || (poi.category == 2393 && zoomLevel < 15) || String(poi.category).hasPrefix("1")
  }
  
  func getAnnotationViewWithIcon(named: String, selected: Bool) -> SKAnnotationView {
    let annotationView = UIView(frame: CGRectMake(0, 0, 14, 14))
    annotationView.backgroundColor = selected ? UIColor.greenColor() : UIColor.whiteColor()
    annotationView.layer.cornerRadius = 7
    let imageView = UIImageView(frame: CGRectMake(1, 1, 12, 12))
    imageView.image = UIImage(named: named)
    annotationView.addSubview(imageView)
    let reuseIdentifier = selected ? "\(named)-selected" : named
    return SKAnnotationView(view: annotationView, reuseIdentifier: reuseIdentifier)
  }
  
  func annotationSelected(annotation: SKAnnotation) -> [SKAnnotation] {
    if annotation.annotationView != nil {
      annotation.annotationView = getAnnotationViewWithIcon(annotation.annotationView.reuseIdentifier, selected: true)
    } else {
      annotation.annotationType = SKAnnotationType.Green
    }
    selectedAnnotation = annotation
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
      if selectedAnnotation.annotationView != nil {
        let reuseIdentifier = selectedAnnotation.annotationView.reuseIdentifier
        let index = reuseIdentifier.endIndex.advancedBy(-9)
        let iconName = reuseIdentifier.substringToIndex(index)
        selectedAnnotation.annotationView = getAnnotationViewWithIcon(iconName, selected: false)
      } else {
        selectedAnnotation.annotationType = SKAnnotationType.Blue
      }
      self.selectedAnnotation = nil
      return [selectedAnnotation]
    } else {
      fatalError()
    }
  }
}