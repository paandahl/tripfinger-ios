package com.tripfinger.map.data;

import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import com.tripfinger.map.data.Bookmark;

import java.util.ArrayList;
import java.util.List;

public enum BookmarkManager
{
  INSTANCE;

  public static final List<Icon> ICONS = new ArrayList<>();

  public static Icon getIconByType(String type)
  {
    for (Icon icon : ICONS)
    {
      if (icon.getType().equals(type))
        return icon;
    }
    // return default icon
    return ICONS.get(0);
  }

  BookmarkManager()
  {
    nativeLoadBookmarks();
  }

  public void deleteBookmark(Bookmark bmk)
  {
    nativeDeleteBookmark(bmk.getCategoryId(), bmk.getBookmarkId());
  }

  public void deleteTrack(Track track)
  {
    nativeDeleteTrack(track.getCategoryId(), track.getTrackId());
  }

  public @NonNull
  BookmarkCategory getCategory(int catId)
  {
    if (catId < nativeGetCategoriesCount())
      return new BookmarkCategory(catId);

    throw new IndexOutOfBoundsException("Invalid category ID!");
  }

  public void toggleCategoryVisibility(int catId)
  {
    BookmarkCategory category = getCategory(catId);
    category.setVisibility(!category.isVisible());
  }

  public Bookmark getBookmark(int catId, int bmkId)
  {
    return getCategory(catId).getBookmark(bmkId);
  }

  public Bookmark addNewBookmark(String name, double lat, double lon)
  {
    final Bookmark bookmark = nativeAddBookmarkToLastEditedCategory(name, lat, lon);
    return bookmark;
  }

  public static native void nativeLoadBookmarks();

  private native void nativeDeleteTrack(int catId, int trackId);

  private native void nativeDeleteBookmark(int cat, int bmkId);

  public native int nativeGetCategoriesCount();

  public native boolean nativeDeleteCategory(int catId);

  /**
   * @return category Id
   */
  public native int nativeCreateCategory(String name);

  public native void nativeShowBookmarkOnMap(int catId, int bmkId);

  /**
   * @return null, if wrong category is passed.
   */
  public native @Nullable
  String nativeSaveToKmzFile(int catId, String tmpPath);

  public native Bookmark nativeAddBookmarkToLastEditedCategory(String name, double lat, double lon);

  public native int nativeGetLastEditedCategory();

  public static native String nativeGenerateUniqueFileName(String baseName);

  public static native boolean nativeLoadKmzFile(String path);

  public static native String nativeFormatNewBookmarkName();
}
