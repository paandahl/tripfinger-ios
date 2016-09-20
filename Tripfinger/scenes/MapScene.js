import React, { Component } from 'react';
import {
  StyleSheet,
  View
} from 'react-native';
import MWMMapView from './../components/MWMMapView'
import { NativeModules } from 'react-native';
var resolveAssetSource = require('resolveAssetSource');

export default class MapScene extends Component {

  render() {
    return (
      <View style={styles.container}>
        <MWMMapView style={styles.map} />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    backgroundColor: '#F5FCFF'
  },
  map: {
    flex: 1
  }
});
