import ReactNative from 'react-native';

// noinspection JSUnresolvedVariable
const Reachability = ReactNative.NativeModules.Reachability;

export default {
  isOnline: async () => await Reachability.isOnline(),
};
