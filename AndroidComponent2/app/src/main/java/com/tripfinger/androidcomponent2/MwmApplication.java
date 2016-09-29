package com.tripfinger.androidcomponent2;

import android.app.Application;
import android.content.pm.PackageManager;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.util.Log;

import java.io.File;

public class MwmApplication extends Application {

  private static final String TAG = MwmApplication.class.getSimpleName();

  private static MwmApplication sSelf;

  private boolean mIsFrameworkInitialized;
  private Handler mMainLoopHandler;
  private final Object mMainQueueToken = new Object();

  public static MwmApplication get()
  {
    return sSelf;
  }

  public MwmApplication()
  {
    super();
    sSelf = this;
  }

  @Override
  public void onCreate() {
    super.onCreate();
    mMainLoopHandler = new Handler(getMainLooper());

    Log.e(TAG, "Started appz");
    initPaths();
    nativeInitPlatform(getApkPath(), getDataStoragePath(), getTempPath(), getObbGooglePath(),
        BuildConfig.FLAVOR, BuildConfig.BUILD_TYPE, false, false);
  }

  private void initPaths()
  {
    new File(getDataStoragePath()).mkdirs();
    new File(getTempPath()).mkdirs();
  }


  public String getApkPath()
  {
    try
    {
      return getPackageManager().getApplicationInfo(BuildConfig.APPLICATION_ID, 0).sourceDir;
    } catch (final PackageManager.NameNotFoundException e)
    {
      Log.e(TAG, "Can't get apk path from PackageManager");
      return "";
    }
  }

  public static String getDataStoragePath()
  {
    return Environment.getExternalStorageDirectory().getAbsolutePath() + "/MapsWithMe/";
  }

  public String getTempPath()
  {
    final File cacheDir = getExternalCacheDir();
    if (cacheDir != null)
      return cacheDir.getAbsolutePath();

    return Environment.getExternalStorageDirectory().getAbsolutePath() +
        String.format("/Android/data/%s/%s/", BuildConfig.APPLICATION_ID, "cache");
  }

  private static String getObbGooglePath()
  {
    final String storagePath = Environment.getExternalStorageDirectory().getAbsolutePath();
    return storagePath.concat(String.format("/Android/obb/%s/", BuildConfig.APPLICATION_ID));
  }

  void forwardToMainThread(final long functorPointer) {
    Message m = Message.obtain(mMainLoopHandler, new Runnable()
    {
      @Override
      public void run()
      {
        nativeProcessFunctor(functorPointer);
      }
    });
    m.obj = mMainQueueToken;
    mMainLoopHandler.sendMessage(m);
  }

  public void initNativeCore()
  {
    if (mIsFrameworkInitialized)
      return;

    nativeInitFramework();

//    MapManager.nativeSubscribe(mStorageCallbacks);

//    initNativeStrings();
//    BookmarkManager.nativeLoadBookmarks();
//    TtsPlayer.INSTANCE.init(this);
//    ThemeSwitcher.restart();
    mIsFrameworkInitialized = true;
  }

  void clearFunctorsOnUiThread()
  {
    mMainLoopHandler.removeCallbacksAndMessages(mMainQueueToken);
  }


  /**
   * Initializes native Platform with paths. Should be called before usage of any other native components.
   */
  private native void nativeInitPlatform(String apkPath, String storagePath, String tmpPath, String obbGooglePath,
      String flavorName, String buildType, boolean isYota, boolean isTablet);

  private static native void nativeInitFramework();

  private static native void nativeProcessFunctor(long functorPointer);


  static {
    System.loadLibrary("native-lib");
  }
}
