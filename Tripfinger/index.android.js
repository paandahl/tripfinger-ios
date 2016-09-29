/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
  AppRegistry,
  Navigator,
  NativeModules,
  StyleSheet,
  Text,
  View,
  Image,
  TouchableHighlight
} from 'react-native';
import CountriesScene from './scenes/CountriesScene';
import MapScene from './scenes/MapScene';

class Tripfinger extends Component {
  render() {
    const navigator = {

    };
    return (
      <Navigator
        initialRoute={{ title: 'Countries', index: 0, component: CountriesScene }}
        renderScene={(route, navigator) => {
          console.log("rendering szene");
          let Component = route.component;
          return <Component navigator={navigator} />
        }}
        navigationBar={
       <Navigator.NavigationBar
         routeMapper={{
           LeftButton: (route, navigator, index, navState) => {
            if (route.index === 0) {
              return null;
            } else {
              return (
                <TouchableHighlight style={styles.leftButton} onPress={() => {
                  navigator.pop();
                  {/*NativeModules.MWMModule.stop();*/}
                  {/*setTimeout(() => navigator.pop(), 6000);*/}
                }}>
                  <Text>&lt; Back</Text>
                </TouchableHighlight>
               );
             }
            },
           RightButton: (route, navigator, index, navState) =>
             { return (
               <View style={styles.rightButton}>
               <TouchableHighlight onPress={() => navigator.push({
                 title: 'Map',
                 index: 1,
                 component: MapScene
               })}>
                <Image source={require('./assets/maps_icon.png')} />
               </TouchableHighlight>
               </View>
               );
             },
           Title: (route, navigator, index, navState) =>
             { return (<Text style={styles.title}>{route.title}</Text>); },
         }}
         style={{
           backgroundColor: 'gray',
           justifyContent: 'center',
           alignItems: 'center'
         }}
       />
    }
        style={{}}
      />
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  leftButton: {
    flex: 1,
    justifyContent: 'center',
  },
  title: {
    flex: 1,
    textAlignVertical: 'center'
  },
  rightButton: {
    flex: 1,
    justifyContent: 'center',
    marginRight: 5
  },
  map: {
    width: 250,
    height: 300
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});

AppRegistry.registerComponent('Tripfinger', () => Tripfinger);
