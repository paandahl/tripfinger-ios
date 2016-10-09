import ReactNative from 'react-native';

const Animated = ReactNative.Animated;
const Dimensions = ReactNative.Dimensions;
const Easing = ReactNative.Easing;
const ListView = ReactNative.ListView;
const PanResponder = ReactNative.PanResponder;

class PanResponderWrapper {

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
export default {
  getScreenHeight: () => Dimensions.get('window').height,
  getScreenWidth: () => Dimensions.get('window').width,

  animateTo: (animatedValue, duration, toValue) => {
    Animated.timing(animatedValue, {
      duration,
      toValue,
      easing: Easing.elastic(0),
    }).start();
  },

  simpleDataSource: () =>
    new ListView.DataSource({
      rowHasChanged: (r1, r2) => {
        console.log(`row has Changedy: ${r1} ${r2}`);
        return true;
      },
      sectionHeaderHasChanged: (s1, s2) => {
        console.log(`sectionHeader has Changed: ${s1} ${s2}`);
        return true;
      },
    }),

  PanResponderWrapper,
};
