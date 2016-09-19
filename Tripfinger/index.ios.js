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
  View,
  NavigatorIOS
} from 'react-native';
import CountriesScene from './CountriesScene'
import MapScene from './MapScene'

class Tripfinger extends Component {

  constructor(props) {
    super(props);
    this.state = {
      navHidden: false
    };
  }

  toggleNavHidden() {
    console.log("Setting navHidden to: " + !this.state.navHidden);
    this.setState({
      navHidden: !this.state.navHidden
    });
  }

  render() {
    return (
      <NavigatorIOS
      navigationBarHidden={this.state.navHidden}
      translucent={true}
      tintColor="#FFF"
      titleTextColor="#FFF"
      initialRoute={{
        component: CountriesScene,
        title: 'Countries',
        passProps: {
          hideBar: () => {this.toggleNavHidden()}
        }
      }}
    //  renderScene={(route, navigator) => {
    //    if (route.title == "Countries") {
    //      return <CountriesScene title={route.title} onForward={ () => {
    //              const nextIndex = route.index + 1;
    //              navigator.push({
    //                title: 'Map',
    //                index: 1
    //              });
    //            }} />
    //    } else {
    //      return <MapScene title={route.title} />
    //    }
    //  }}
    //  navigationBar={
    // <Navigator.NavigationBar
    //   routeMapper={{
    //     LeftButton: (route, navigator, index, navState) =>
    //      { return (<Text>Cancel</Text>); },
    //     RightButton: (route, navigator, index, navState) =>
    //       { return (<Text>Done</Text>); },
    //     Title: (route, navigator, index, navState) =>
    //       { return (<Text>Awesome Nav Bar</Text>); },
    //   }}
    //   style={{backgroundColor: 'gray'}}
    // />
    //}
    style={{flex: 1}}
    />
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
