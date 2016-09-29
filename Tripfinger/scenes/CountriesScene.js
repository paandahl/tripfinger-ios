import React, { Component, PropTypes } from 'react';
import {
  StyleSheet,
  Text,
  View,
  TouchableHighlight
} from 'react-native';
import MapScene from './MapScene'
import { NativeModules } from 'react-native';
var NavBarManager = NativeModules.NavBarManager;
var resolveAssetSource = require('resolveAssetSource');
const MAP_ACTION = 'mapAction';
const SETTINGS_ACTION = 'settingsAction';

export default class CountriesScene extends Component {
  static propTypes = {
    navigator: PropTypes.object.isRequired
  };

  static title() {
    return "Countries";
  }

  static rightButtonActions() {
    return [
      {action: MAP_ACTION, res: resolveAssetSource(require('../assets/maps_icon.png'))},
      {action: SETTINGS_ACTION, res: resolveAssetSource(require('../assets/ic_menu.png'))}
    ];
  }

  constructor(props) {
    super(props);
    this.state = {
      displaySettings: false
    };
  }

  rightButtonPressed(action) {
    switch (action) {
      case MAP_ACTION:
        this.navigateToMap();
        break;
      case SETTINGS_ACTION:
        this.toggleSettings();
        break;
      default:
        console.log("Unrecognized action: " + action);
    }
  }

  navigateToMap() {
    this.props.navigator.push({
      component: MapScene,
      title: 'Map',
    });
  }

  toggleSettings() {
    this.setState({
      displaySettings: !this.state.displaySettings
    });
  }

  hideNavBar() {
    NavBarManager.toggleNavBarHidden();
  }

  componentWillUpdate() {
    console.log("CountriesScene will updatesz");
  }

  render() {
    let settings;
    if (this.state.displaySettings) {
      settings =
        <View style={styles.settingsOverlay}>
          <View style={styles.settings} />
        </View>
    }

    return (
      <View style={styles.container}>
        {settings}
        <Text style={styles.welcome}>
          Welcome, Naya!
        </Text>
        <TouchableHighlight style={styles.mapButton} underlayColor="#AAA"
          onPress={() => this.hideNavBar()}>
          <Text style={styles.mapButtonLabel}>Hide</Text>
        </TouchableHighlight>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignSelf: 'stretch',
    backgroundColor: '#F5FCFF'
  },
  welcome: {
    alignSelf: 'center',
    fontSize: 20,
    height: 50,
    marginBottom: 40
  },
  mapButton: {
    padding: 20,
    width: 200,
    alignSelf: 'center',
    backgroundColor: '#CCC'
  },
  mapButtonLabel: {
    fontSize: 20,
    textAlign: 'center'
  },
  settingsOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    zIndex: 100,
    backgroundColor: '#00000077'
  },
  settings: {
    backgroundColor: '#FFF',
    height: 200
  }
});
