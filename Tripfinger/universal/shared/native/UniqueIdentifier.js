import ReactNative from 'react-native';

// noinspection JSUnresolvedVariable
const UniqueIdentifieNative = ReactNative.NativeModules.UniqueIdentifier;

export default class UniqueIdentifier {
  // noinspection JSUnresolvedFunction
  static getIdentifier = async () => await UniqueIdentifieNative.getIdentifier();
}
