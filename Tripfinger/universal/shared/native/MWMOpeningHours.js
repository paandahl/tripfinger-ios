import ReactNative from 'react-native';

// noinspection JSUnresolvedVariable
const MWMOpeningHoursNative = ReactNative.NativeModules.MWMOpeningHours;

export default class MWMOpeningHours {

  static async createOpeningHoursDict(timeString) {
    // noinspection JSUnresolvedFunction
    return await MWMOpeningHoursNative.createOpeningHoursDict(timeString);
  }
}
