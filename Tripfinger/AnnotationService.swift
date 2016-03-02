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
          annotationGroups[annotation]!.append(poi)
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
    let pois = annotationGroups[annotation]!
    if pois.count > 1 {
      annotation.annotationView = nil
      if selected {
        annotation.annotationType = SKAnnotationType.Green
      } else {
        annotation.annotationType = SKAnnotationType.Purple
      }
    } else {
      
      let poi = pois[0]
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
        } else {
          annotation.annotationType = SKAnnotationType.Blue
        }
      }
    }
  }
  
  private func getAnnotationViewWithIcon(named: String, selected: Bool) -> SKAnnotationView {
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
      fatalError()
    }
  }
}