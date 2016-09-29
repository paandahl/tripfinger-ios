package com.tripfinger.map;

import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;

public class MWMMapViewManager extends SimpleViewManager<MiddleView> {

  public static final String REACT_CLASS = "MWMMapView";
  public static MWMMapView mapView = null;
  public static MiddleView middleView = null;

  @Override
  public String getName() {
    return REACT_CLASS;
  }

  @Override
  protected MiddleView createViewInstance(ThemedReactContext reactContext) {
    if (mapView == null) {
      mapView = new MWMMapView(reactContext);
    }
    if (middleView == null) {
      middleView = new MiddleView(reactContext);
    }
    return middleView;
  }
}
