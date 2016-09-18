/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View
} from 'react-native';
import TestView from './TestView';
import MWMMapView from './MWMMapView'

class Tripfinger extends Component {
  render() {
    return (
      <View style={styles.container}>
        {/*<Text style={styles.welcome}>
          Welcome to React Native!
        </Text>
        <TestView style={{width: 200, height: 60}} />*/}
        <MWMMapView style={styles.map} />
        {/*<Text style={styles.instructions}>
          To get started, edit index.ios.js
        </Text>
        <Text style={styles.instructions}>
          Press Cmd+R to reload,{'\n'}
          Cmd+D or shake for dev menu
        </Text>*/}
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
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5
  },
});

AppRegistry.registerComponent('Tripfinger', () => Tripfinger);
