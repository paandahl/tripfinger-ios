package com.tripfinger.map;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

public class MWMMapModule extends ReactContextBaseJavaModule {

  public MWMMapModule(ReactApplicationContext reactContext) {
    super(reactContext);
  }

  @Override
  public String getName() {
    return "MWMModule";
  }

  @ReactMethod
  public void stop() {
    MWMMapViewManager.mapView.stop();
  }
}
