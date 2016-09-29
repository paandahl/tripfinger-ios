package com.tripfinger.map;

import android.content.Context;
import android.graphics.Color;
import android.util.Log;
import android.view.ViewGroup;

public class MiddleView extends ViewGroup {

  private final String TAG = MiddleView.class.getSimpleName();

  public MiddleView(Context context) {
    super(context);
    setBackgroundColor(Color.RED);
    addView(MWMMapViewManager.mapView);
  }

  @Override
  protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
    Log.e(TAG, String.format("onLayout(%s,%s,%s,%s)", left, top, right, bottom));
    getChildAt(0).layout(left, top, right, bottom);
  }
}
