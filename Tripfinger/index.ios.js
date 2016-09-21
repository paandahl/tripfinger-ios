import React, { Component } from 'react';
import {
  AppRegistry,
  NativeModules,
  StyleSheet
} from 'react-native';
import TFNavigator from './components/TFNavigator'
import CountriesScene from './scenes/CountriesScene'

const BookmarkService = NativeModules.BookmarkService;
BookmarkService.initializeFirebase();

class Tripfinger extends Component {

  render() {
    return (
      <TFNavigator
      translucent={true}
      tintColor="#FFF"
      titleTextColor="#FFF"
      initialRoute={{
        component: CountriesScene,
        title: 'Countries'
      }}
      style={styles.navigator}
    />
    );
  }
}

const styles = StyleSheet.create({
  navigator: {
    flex: 1
  }
});

AppRegistry.registerComponent('Tripfinger', () => Tripfinger);
