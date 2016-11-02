import React from 'react';
import ReactNative from 'react-native';
import CountriesScene from './universal/guide/regions/CountriesScene';
import MapScene from './universal/map/MapScene';
import Utils from './universal/shared/Utils';

const Component = React.Component;
const AppRegistry = ReactNative.AppRegistry;
const Navigator = ReactNative.Navigator;
const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;
const View = ReactNative.View;
const Image = ReactNative.Image;
const TouchableHighlight = ReactNative.TouchableHighlight;

const MAP_ICON = require('./assets/maps_icon.png');

class Tripfinger extends Component {

  static renderLeftButton(route, navigator) {
    if (route.index === 0) {
      return null;
    }
    return (
      <TouchableHighlight
        style={styles.leftButton}
        onPress={() => navigator.pop()}
      >
        <Text>{'<'} Back</Text>
      </TouchableHighlight>
    );
  }

  static renderRightButton(navigator) {
    return (
      <View style={styles.rightButton}>
        <TouchableHighlight
          onPress={() => {
            navigator.push({
              title: 'Map',
              index: 1,
              component: MapScene,
            });
          }}
        >
          <Image source={MAP_ICON} />
        </TouchableHighlight>
      </View>
    );
  }

  constructor(props) {
    super(props);
    Utils.initializeApp();
  }

  render() {
    // noinspection JSUnusedGlobalSymbols
    return (
      <Navigator
        initialRoute={{ title: 'Countries', index: 0, component: CountriesScene }}
        renderScene={(route, navigator) => {
          const Scene = route.component;
          return <Scene navigator={navigator} />;
        }}
        navigationBar={
          <Navigator.NavigationBar
            routeMapper={{
              LeftButton: Tripfinger.renderLeftButton,
              RightButton: (route, navigator) => Tripfinger.renderRightButton(navigator),
              Title: route => <Text style={styles.title}>{route.title}</Text>,
            }}
            style={styles.navBar}
          />
        }
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
  navBar: {
    backgroundColor: 'gray',
    justifyContent: 'center',
    alignItems: 'center',
  },
  leftButton: {
    flex: 1,
    justifyContent: 'center',
  },
  title: {
    flex: 1,
    textAlignVertical: 'center',
  },
  rightButton: {
    flex: 1,
    justifyContent: 'center',
    marginRight: 5,
  },
  map: {
    width: 250,
    height: 300,
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
