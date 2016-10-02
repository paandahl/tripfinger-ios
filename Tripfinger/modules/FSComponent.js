import ReactNative from 'react-native';

// noinspection JSUnresolvedVariable
const FSComponent = ReactNative.NativeModules.FSComponent;

export default {
  downloadFile: (url, filename, callback) => {
    FSComponent.downloadFile(url, filename, callback);
  },
};
