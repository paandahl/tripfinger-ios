package com.tripfinger.map;

public class Framework {

  public interface PoiSupplier {
    void poiSupplier();
  }

  public static native void nativeSetPoiSupplier(PoiSupplier supplier);
}
