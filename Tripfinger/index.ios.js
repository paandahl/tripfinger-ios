import React from 'react';
import ReactNative from 'react-native';
import TFNavigator from './universal/shared/native/TFNavigator';
import CountriesScene from './universal/guide/regions/CountriesScene';
import BookmarkService from './universal/shared/native/BookmarkService';
import Utils from './universal/shared/Utils';

const Component = React.Component;
const AppRegistry = ReactNative.AppRegistry;
const StyleSheet = ReactNative.StyleSheet;

BookmarkService.initializeFirebase();

class Tripfinger extends Component {

  constructor(props) {
    super(props);
    Utils.initializeApp();
  }

  // noinspection JSMethodCanBeStatic
  render() {
    return (
      <TFNavigator
        translucent
        tintColor="#FFF"
        titleTextColor="#FFF"
        initialRoute={{
          component: CountriesScene,
        }}
        style={styles.navigator}
        interactivePopGestureEnabled={false}
      />
    );
  }
}

const styles = StyleSheet.create({
  navigator: {
    flex: 1,
  },
});

AppRegistry.registerComponent('Tripfinger', () => Tripfinger);
