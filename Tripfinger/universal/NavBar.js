import React from 'react';
import ReactNative from 'react-native';
import MapScene from './map/MapScene';
import Globals from './shared/Globals';
import CountriesScene from './guide/regions/CountriesScene';
import SearchScene from './search/SearchScene';

const Image = ReactNative.Image;
const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;
const TouchableOpacity = ReactNative.TouchableOpacity;
const View = ReactNative.View;

const BACK_ICON = require('../assets/back_icon.png');

export default class NavBar extends React.Component {

  static propTypes = {
    style: React.PropTypes.any,
    navigator: React.PropTypes.object.isRequired,
    sceneProps: React.PropTypes.object.isRequired,
    actions: React.PropTypes.array,
  };

  static defaultProps = {
    style: {},
  };

  _renderBackButton() {
    if (this.props.sceneProps.scene.index === 0) {
      return null;
    }
    const titleLength = this.props.sceneProps.scene.route.title.length;
    const previousSceneIndex = this.props.sceneProps.scene.index - 1;
    const previousSceneTitle = this.props.sceneProps.scenes[previousSceneIndex].route.title;
    const backTitle = titleLength <= 25 ? previousSceneTitle : '';
    const pop = this.props.navigator.pop;
    return (
      <TouchableOpacity style={styles.backButton} onPress={pop}>
        <View style={styles.backButtonContainer}>
          <Image style={styles.backButtonIcon} source={BACK_ICON} />
          <Text style={styles.backButtonText}>{backTitle}</Text>
        </View>
      </TouchableOpacity>
    );
  }

  render() {
    const containerStyle = [styles.container, this.props.style];
    return (
      <View style={containerStyle}>
        {this._renderBackButton()}
        <Text style={styles.title}>{this.props.sceneProps.scene.route.title}</Text>
        <View style={styles.rightButtons}>
          {this.props.actions && this.props.actions.map((action, index) =>
            <TouchableOpacity key={index} style={styles.rightButton} onPress={action.action}>
              <Image style={styles.rightButtonImage} source={action.res} />
            </TouchableOpacity>
          )}
        </View>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    zIndex: 500,
    alignItems: 'center',
    left: 0,
    right: 0,
    height: 64,
    backgroundColor: `${Globals.colors.tripfingerBlue}cc`,
  },
  backButton: {
    position: 'absolute',
    top: 20,
    left: 0,
    height: 44,
    padding: 10,
  },
  backButtonIcon: {
    tintColor: '#fff',
  },
  backButtonText: {
    marginLeft: 5,
    fontSize: 18,
    color: '#fff',
  },
  backButtonContainer: {
    flexDirection: 'row',
  },
  title: {
    top: 30,
    fontSize: 18,
    fontWeight: '400',
    color: '#fff',
  },
  rightButtons: {
    flexDirection: 'row',
    position: 'absolute',
    top: 15,
    right: 0,
    padding: 10,
  },
  rightButton: {
    padding: 5,
    paddingLeft: 15,
  },
  rightButtonImage: {
    tintColor: '#fff',
  },
});
