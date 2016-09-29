package com.tripfinger.map;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Rect;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.MotionEvent;
import android.view.Surface;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.WindowManager;

import com.tripfinger.BuildConfig;
import com.tripfinger.MainApplication;
import com.tripfinger.R;
import com.tripfinger.map.util.UiUtils;

public class MWMMapView extends SurfaceView implements SurfaceHolder.Callback {

  private static final String TAG = SurfaceView.class.getSimpleName();

  // Should correspond to android::MultiTouchAction from Framework.cpp
  private static final int NATIVE_ACTION_UP = 0x01;
  private static final int NATIVE_ACTION_DOWN = 0x02;
  private static final int NATIVE_ACTION_MOVE = 0x03;
  private static final int NATIVE_ACTION_CANCEL = 0x04;

  // Should correspond to gui::EWidget from skin.hpp
  private static final int WIDGET_RULER = 0x01;
  private static final int WIDGET_COMPASS = 0x02;
  private static final int WIDGET_COPYRIGHT = 0x04;
  private static final int WIDGET_SCALE_LABEL = 0x08;

  // Should correspond to dp::Anchor from drape_global.hpp
  private static final int ANCHOR_CENTER = 0x00;
  private static final int ANCHOR_LEFT = 0x01;
  private static final int ANCHOR_RIGHT = (ANCHOR_LEFT << 1);
  private static final int ANCHOR_TOP = (ANCHOR_RIGHT << 1);
  private static final int ANCHOR_BOTTOM = (ANCHOR_TOP << 1);
  private static final int ANCHOR_LEFT_TOP = (ANCHOR_LEFT | ANCHOR_TOP);
  private static final int ANCHOR_RIGHT_TOP = (ANCHOR_RIGHT | ANCHOR_TOP);
  private static final int ANCHOR_LEFT_BOTTOM = (ANCHOR_LEFT | ANCHOR_BOTTOM);
  private static final int ANCHOR_RIGHT_BOTTOM = (ANCHOR_RIGHT | ANCHOR_BOTTOM);

  // Should correspond to df::TouchEvent::INVALID_MASKED_POINTER from user_event_stream.cpp
  private static final int INVALID_POINTER_MASK = 0xFF;
  private static final int INVALID_TOUCH_ID = -1;

  private int mHeight;
  private int mWidth;
  private static boolean sWasCopyrightDisplayed;

  private boolean mEngineCreated;
  private boolean mRequireResize;

  public MWMMapView(Context context) {
    super(context);
    getHolder().addCallback(this);
    setBackgroundColor(Color.WHITE);
  }

  @Override
  public void surfaceCreated(SurfaceHolder surfaceHolder) {

    setBackgroundColor(Color.TRANSPARENT);
    Log.e(TAG, "surfaceCreated");
    final Surface surface = surfaceHolder.getSurface();
    if (nativeIsEngineCreated())
    {
      Log.e(TAG, "attaching surface");
      nativeAttachSurface(surface);
      mRequireResize = true;
      return;
    } else {
      Log.e(TAG, "skipped attaching surface");
    }

    mRequireResize = false;
    final Rect rect = surfaceHolder.getSurfaceFrame();
    setupWidgets(rect.width(), rect.height());

    final DisplayMetrics metrics = new DisplayMetrics();
    WindowManager wMgr = ((WindowManager) getContext().getSystemService(Context.WINDOW_SERVICE));
    wMgr.getDefaultDisplay().getMetrics(metrics);

    final float exactDensityDpi = metrics.densityDpi;

    mEngineCreated = nativeCreateEngine(surface, (int) exactDensityDpi);
    if (!mEngineCreated)
    {
      reportUnsupported();
      return;
    }

    onRenderingInitialized();
  }

  @Override
  protected void onDetachedFromWindow() {
    super.onDetachedFromWindow();
    Log.e(TAG, "onDetachedFromWindow");
  }

  @Override
  public void onStartTemporaryDetach() {
    super.onStartTemporaryDetach();
    Log.e(TAG, "onStartTemporaryDetach");
  }



  @Override
  public void surfaceChanged(SurfaceHolder surfaceHolder, int format, int width, int height) {
    Log.e(TAG, "mEngineCreated: " + mEngineCreated);
    Log.e(TAG, "mRequireResize: " + mRequireResize);
    Log.e(TAG, "surfaceHolder.isCreating(): " + surfaceHolder.isCreating());
    if (!mEngineCreated ||
        (!mRequireResize && surfaceHolder.isCreating())) {
      Log.e(TAG, "returning from surfaceChanged");
      return;
    }
    Log.e(TAG, "staying in surfaceChanged");

    nativeSurfaceChanged(width, height);

    mRequireResize = false;
    setupWidgets(width, height);
    nativeApplyWidgets();
  }

  @Override
  public void surfaceDestroyed(SurfaceHolder surfaceHolder) {
    Log.e(TAG, "surfaceDestroyed");
    if (!mEngineCreated)
      return;

    nativeDetachSurface();
    setBackgroundColor(Color.WHITE);
//    if (getActivity() == null || !getActivity().isChangingConfigurations())
//      destroyEngine();
//    else
//    ((ThemedReactContext)getContext()).getCurrentActivity().recreate();

  }

  interface MapRenderingListener
  {
    void onRenderingInitialized();
  }

  private void setupWidgets(int width, int height)
  {
    mHeight = height;
    mWidth = width;

    nativeCleanWidgets();
    if (!sWasCopyrightDisplayed)
    {
      nativeSetupWidget(WIDGET_COPYRIGHT,
          mWidth - UiUtils.dimen(R.dimen.margin_ruler_right),
          mHeight - UiUtils.dimen(R.dimen.margin_ruler_bottom),
          ANCHOR_RIGHT_BOTTOM);
      sWasCopyrightDisplayed = true;
    }

    nativeSetupWidget(WIDGET_RULER,
        mWidth - UiUtils.dimen(R.dimen.margin_ruler_right),
        mHeight - UiUtils.dimen(R.dimen.margin_ruler_bottom),
        ANCHOR_RIGHT_BOTTOM);

    if (BuildConfig.DEBUG)
    {
      nativeSetupWidget(WIDGET_SCALE_LABEL,
          UiUtils.dimen(R.dimen.margin_base),
          UiUtils.dimen(R.dimen.margin_base),
          ANCHOR_LEFT_TOP);
    }

    setupCompass(0, 0, false);
  }

  void setupCompass(int offsetX, int offsetY, boolean forceRedraw)
  {
    nativeSetupWidget(WIDGET_COMPASS,
        UiUtils.dimen(R.dimen.margin_compass_left) + offsetX,
        mHeight - UiUtils.dimen(R.dimen.margin_compass_bottom) + offsetY,
        ANCHOR_CENTER);
    if (forceRedraw && mEngineCreated)
      nativeApplyWidgets();
  }

  void setupRuler(int offsetX, int offsetY, boolean forceRedraw)
  {
    nativeSetupWidget(WIDGET_RULER,
        mWidth - UiUtils.dimen(R.dimen.margin_ruler_right) + offsetX,
        mHeight - UiUtils.dimen(R.dimen.margin_ruler_bottom) + offsetY,
        ANCHOR_RIGHT_BOTTOM);
    if (forceRedraw && mEngineCreated)
      nativeApplyWidgets();
  }

  private void onRenderingInitialized()
  {
//    final Activity activity = getActivity();
//    if (isAdded() && activity instanceof MapRenderingListener)
//      ((MapRenderingListener) activity).onRenderingInitialized();
  }

  private void reportUnsupported()
  {
    throw new RuntimeException("reportUnsupported");
//    new AlertDialog.Builder(getActivity())
//        .setMessage(getString(R.string.unsupported_phone))
//        .setCancelable(false)
//        .setPositiveButton(getString(R.string.close), new DialogInterface.OnClickListener()
//        {
//          @Override
//          public void onClick(DialogInterface dlg, int which)
//          {
//            getActivity().moveTaskToBack(true);
//          }
//        }).show();
  }

  void destroyEngine()
  {
    if (!mEngineCreated)
      return;

    // We're in the main thread here. So nothing from the queue will be run between these two calls.
    // Destroy engine first, then clear the queue that theoretically can be filled by nativeDestroyEngine().
    nativeDestroyEngine();
    MainApplication.get().clearFunctorsOnUiThread();
    mEngineCreated = false;
  }

  @Override
  public boolean onTouchEvent(MotionEvent event) {
    final int count = event.getPointerCount();

    if (count == 0)
      return false;

    int action = event.getActionMasked();
    int pointerIndex = event.getActionIndex();
    switch (action)
    {
      case MotionEvent.ACTION_POINTER_UP:
        action = NATIVE_ACTION_UP;
        break;
      case MotionEvent.ACTION_UP:
        action = NATIVE_ACTION_UP;
        pointerIndex = 0;
        break;
      case MotionEvent.ACTION_POINTER_DOWN:
        action = NATIVE_ACTION_DOWN;
        break;
      case MotionEvent.ACTION_DOWN:
        action = NATIVE_ACTION_DOWN;
        pointerIndex = 0;
        break;
      case MotionEvent.ACTION_MOVE:
        action = NATIVE_ACTION_MOVE;
        pointerIndex = INVALID_POINTER_MASK;
        break;
      case MotionEvent.ACTION_CANCEL:
        action = NATIVE_ACTION_CANCEL;
        break;
    }

    switch (count)
    {
      case 1:
        nativeOnTouch(action, event.getPointerId(0), event.getX(), event.getY(), INVALID_TOUCH_ID, 0, 0, 0);
        return true;
      default:
        nativeOnTouch(action,
            event.getPointerId(0), event.getX(0), event.getY(0),
            event.getPointerId(1), event.getX(1), event.getY(1), pointerIndex);
        return true;
    }
  }

  public void stop() {


//    nativeDetachSurface();
//    Canvas canvas = getHolder().getSurface().lockHardwareCanvas();
//    canvas.drawColor(0, PorterDuff.Mode.CLEAR);
//    getHolder().unlockCanvasAndPost(canvas);
//    getHolder().setFormat(PixelFormat.TRANSPARENT);

//    ((ThemedReactContext) getContext()).getCurrentActivity().runOnUiThread(new Runnable() {
//      @Override
//      public void run() {
//        MWMMapView.this.setVisibility(GONE);
//      }
//    });
  }

  static native boolean nativeIsEngineCreated();
  private static native boolean nativeCreateEngine(Surface surface, int density);
  private static native void nativeDestroyEngine();
  private static native void nativeAttachSurface(Surface surface);
  private static native void nativeDetachSurface();
  private static native void nativeSurfaceChanged(int w, int h);
  private static native void nativeOnTouch(int actionType, int id1, float x1, float y1, int id2, float x2, float y2, int maskedPointer);
  private static native void nativeSetupWidget(int widget, float x, float y, int anchor);
  private static native void nativeApplyWidgets();
  private static native void nativeCleanWidgets();
}
