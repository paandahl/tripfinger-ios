import React from 'react';
import ReactNative from 'react-native';
import TFNavigator from './components/TFNavigator';
import CountriesScene from './scenes/CountriesScene';
import BookmarkService from './modules/BookmarkService';

const Component = React.Component;
const AppRegistry = ReactNative.AppRegistry;
const StyleSheet = ReactNative.StyleSheet;

BookmarkService.initializeFirebase();

class Tripfinger extends Component {

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
