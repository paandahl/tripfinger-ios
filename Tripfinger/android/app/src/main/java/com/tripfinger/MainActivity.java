package com.tripfinger;

import android.os.Bundle;
import android.util.Log;

import com.facebook.react.ReactActivity;
import com.tripfinger.map.Framework;

public class MainActivity extends ReactActivity implements Framework.PoiSupplier {

    /**
     * Returns the name of the main component registered from JavaScript.
     * This is used to schedule rendering of the component.
     */
    @Override
    protected String getMainComponentName() {
        return "Tripfinger";
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        MainApplication.get().initNativeCore();
        Framework.nativeSetPoiSupplier(this);

        // Example of a call to a native method
//    TextView tv = (TextView) findViewById(R.id.sample_text);
//    tv.setText(stringFromJNI());
    }

    @Override
    public void poiSupplier() {
        Log.e("FACK", "poiSupplier was called, aight!");
    }

}
