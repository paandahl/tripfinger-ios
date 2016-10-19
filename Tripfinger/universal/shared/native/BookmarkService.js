import ReactNative from 'react-native';

// noinspection JSUnresolvedVariable
const NativeBookmarkService = ReactNative.NativeModules.BookmarkService;

export default class BookmarkService {

  static initializeFirebase() {
    NativeBookmarkService.initializeFirebase();
  }

  static async addBookmarkForItem(item) {
    const bookmark = {};
    bookmark.name = item.name;
    bookmark.latitude = item.latitude;
    bookmark.longitude = item.longitude;
    console.log(`adding bookmark with latlon: ${bookmark.latitude} , ${bookmark.longitude}`);
    return await NativeBookmarkService.addBookmark(bookmark);
  }

  static removeBookmarkForItem(item) {
    return NativeBookmarkService.removeBookmark(item.bookmarkKey);
  }
}
