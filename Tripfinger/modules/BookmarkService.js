import ReactNative from 'react-native';

// noinspection JSUnresolvedVariable
const BookmarkService = ReactNative.NativeModules.BookmarkService;

export default {
  initializeFirebase: () => {
    BookmarkService.initializeFirebase();
  },
};
