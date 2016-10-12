import ReactNative from 'react-native';

const Animated = ReactNative.Animated;
const Dimensions = ReactNative.Dimensions;
const Easing = ReactNative.Easing;
const ListView = ReactNative.ListView;
const PanResponder = ReactNative.PanResponder;

const EARTH_RADIUS_IN_METERS = 6378000;

class PanResponderWrapperClass {

  constructor(handlers) {
    // noinspection JSUnusedGlobalSymbols
    this.panResponder = PanResponder.create({
      onStartShouldSetPanResponderCapture: () => false,
      onMoveShouldSetPanResponderCapture: () => true,
      onPanResponderGrant: () => {
        // noinspection JSUnresolvedFunction
        this.panStartY = handlers.getStartValue();
      },
      onPanResponderMove: (evt, gestureState) => {
        handlers.onPanResponderMove(evt, gestureState, this.panStartY);
      },
      onPanResponderTerminationRequest: () => false,
      onPanResponderRelease: handlers.onPanResponderRelease,
      onPanResponderTerminate: () => handlers.onPanResponderTerminate(this.panStartY),
    });
  }

  panHandlers = () => this.panResponder.panHandlers;
}

// noinspection JSUnusedGlobalSymbols
export default class Utils {
  static getScreenHeight = () => Dimensions.get('window').height;
  static getScreenWidth = () => Dimensions.get('window').width;

  static animateTo = (animatedValue, duration, toValue) => {
    Animated.timing(animatedValue, {
      duration,
      toValue,
      easing: Easing.elastic(0),
    }).start();
  };

  static simpleDataSource = () =>
    new ListView.DataSource({
      rowHasChanged: (r1, r2) => r1 !== r2,
      sectionHeaderHasChanged: (s1, s2) => s1 !== s2,
    });

  static PanResponderWrapper = PanResponderWrapperClass;

  static distanceOnEarth = (sourceLat, sourceLon, targetLat, targetLon) =>
    EARTH_RADIUS_IN_METERS * Utils.distanceOnSphere(sourceLat, sourceLon, targetLat, targetLon);

  static distanceOnSphere = (lat1Deg, lon1Deg, lat2Deg, lon2Deg) => {
    const lat1 = Utils.degToRad(lat1Deg);
    const lat2 = Utils.degToRad(lat2Deg);
    const dlat = Math.sin((lat2 - lat1) * 0.5);
    const dlon = Math.sin((Utils.degToRad(lon2Deg) - Utils.degToRad(lon1Deg)) * 0.5);
    const y = (dlat * dlat) + (dlon * dlon * Math.cos(lat1) * Math.cos(lat2));
    return 2.0 * Math.atan2(Math.sqrt(y), Math.sqrt(Math.max(0.0, 1.0 - y)));
  };

  static degToRad(deg) {
    return (deg * Math.PI) / 180;
  }

  static formatDistance(distance) {
    // TODO: add support for imperial units
    // if (false) {
    //   return Utils._formatDistance(distance, ' mi', ' ft', 1609.344, 0.3048);
    // }
    return Utils._formatDistance(distance, ' km', ' m', 1000.0, 1.0);
  }

  static _formatDistance(distance, highLabel, lowLabel, highFactor, lowFactor) {
    const lowCount = distance / lowFactor;
    if (lowCount < 1.0) {
      return `0${lowLabel}`;
    }

    // To display any lower units only if < 1000
    if (distance >= 1000.0 * lowFactor) {
      const v = distance / highFactor;
      if (v >= 10.0) {
        return Math.round(v) + highLabel;
      }
      return v.toFixed(1) + highLabel;
    }
    return Math.round(lowCount, 0) + lowLabel;
  }
}
