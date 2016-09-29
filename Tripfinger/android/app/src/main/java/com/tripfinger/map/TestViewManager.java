package com.tripfinger.map;

import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;

public class TestViewManager extends SimpleViewManager<TestView> {

  public static final String REACT_CLASS = "RCTTestView";

  @Override
  public String getName() {
    return REACT_CLASS;
  }

  @Override
  protected TestView createViewInstance(ThemedReactContext reactContext) {
    return new TestView(reactContext);
  }
}
