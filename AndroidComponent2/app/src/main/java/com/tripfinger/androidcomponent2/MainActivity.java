package com.tripfinger.androidcomponent2;

import android.os.Bundle;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;

import com.tripfinger.androidcomponent2.base.BaseMwmFragmentActivity;

public class MainActivity extends BaseMwmFragmentActivity implements
    View.OnTouchListener,
    Framework.PoiSupplier {

  private View mMapFrame;
  private MapFragment mMapFragment;
  private boolean mIsFragmentContainer;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    mIsFragmentContainer = false;

    setContentView(R.layout.activity_main);
    initViews();

    Framework.nativeSetPoiSupplier(this);

    // Example of a call to a native method
//    TextView tv = (TextView) findViewById(R.id.sample_text);
//    tv.setText(stringFromJNI());
  }

  private void initViews()
  {
    initMap();
//    initYota();
//    initPlacePage();
//    initNavigationButtons();

    if (!mIsFragmentContainer)
    {
//      mRoutingPlanInplaceController = new RoutingPlanInplaceController(this);
//      removeCurrentFragment(false);
    }

//    mNavigationController = new NavigationController(this);
//    RoutingController.get().attach(this);
//    initMenu();
//    initOnmapDownloader();
//    initPositionChooser();
  }

  private void initMap()
  {
    mMapFrame = findViewById(R.id.map_fragment_container);

//    mFadeView = (FadeView) findViewById(R.id.fade_view);
//    mFadeView.setListener(new FadeView.Listener()
//    {
//      @Override
//      public boolean onTouch()
//      {
//        return mMainMenu.close(true);
//      }
//    });

    mMapFragment = (MapFragment) getSupportFragmentManager().findFragmentByTag(MapFragment.class.getName());
    if (mMapFragment == null)
    {
      mMapFragment = (MapFragment) MapFragment.instantiate(this, MapFragment.class.getName(), null);
      getSupportFragmentManager()
          .beginTransaction()
          .replace(R.id.map_fragment_container, mMapFragment, MapFragment.class.getName())
          .commit();
    }
    mMapFrame.setOnTouchListener(this);
  }

  @Override
  public boolean onTouch(View view, MotionEvent event)
  {
//    return mPlacePage.hideOnTouch() ||
    return mMapFragment.onTouch(view, event);
  }


  /**
   * A native method that is implemented by the 'native-lib' native library,
   * which is packaged with this application.
   */
  public native String stringFromJNI();

  @Override
  public void poiSupplier() {
    Log.e("FACK", "poiSupplier was called, aight!");
  }

  // Used to load the 'native-lib' library on application startup.
}
