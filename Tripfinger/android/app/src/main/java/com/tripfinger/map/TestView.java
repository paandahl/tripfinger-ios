package com.tripfinger.map;

import android.content.Context;
import android.widget.TextView;

public class TestView extends TextView {

  public TestView(Context context) {
    super(context);
    setText(hello());
  }

  public native String hello();
}
