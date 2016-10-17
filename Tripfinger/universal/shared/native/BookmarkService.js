import ReactNative from 'react-native';

// noinspection JSUnresolvedVariable
const NativeBookmarkService = ReactNative.NativeModules.BookmarkService;

export default class BookmarkService {

  static initializeFirebase() {
    NativeBookmarkService.initializeFirebase();
  }

  static async addBookmarkForItem(item) {
    const bookmark = {};
    bookmark.name = item.title;
    bookmark.latitude = item.lat / 1000000;
    bookmark.longitude = item.lon / 1000000;
    return await NativeBookmarkService.addBookmark(bookmark);
  }

  static removeBookmarkForItem(item) {
    return NativeBookmarkService.removeBookmark(item.bookmarkKey);
  }
}
