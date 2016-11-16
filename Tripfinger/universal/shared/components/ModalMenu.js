import React from 'react';
import ReactNative from 'react-native';
import Globals from '../Globals';
import SearchScene from '../../search/SearchScene';

const Image = ReactNative.Image;
const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;
const TouchableHighlight = ReactNative.TouchableHighlight;
const View = ReactNative.View;

const SEARCH_ICON = require('../../../assets/search_icon.png');
const SETTINGS_ICON = require('../../../assets/settings_icon.png');

export default class ModalMenu extends React.Component {

  static MENU_ICON = require('../../../assets/ic_menu.png');

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    navigator: React.PropTypes.object,
  };

  constructor(props) {
    super(props);
    this.state = {
      displayMenu: false,
    };
  }

  toggleSettings = () => {
    this.setState({
      displayMenu: !this.state.displayMenu,
    });
  };

  _navigateToSearch = async () => {
    // const dataProps = await SearchScene.fetchData();
    this.props.navigator.push({
      scene: SearchScene,
    });
    this.setState({
      displayMenu: false,
    });
  };


  render() {
    if (!this.state.displayMenu) {
      return null;
    }
    return (
      <View style={styles.settingsOverlay}>
        <View style={styles.settings}>
          <TouchableHighlight onPress={this._navigateToSearch}>
            <View style={styles.settingsRow}>
              <Image source={SEARCH_ICON} style={styles.settingsIcon} />
              <View style={styles.settingsInnerRow}>
                <Text>Search</Text>
              </View>
            </View>
          </TouchableHighlight>
          <View style={styles.settingsRow}>
            <Image source={SETTINGS_ICON} style={styles.settingsIcon} />
            <View style={styles.settingsInnerRow}>
              <Text>Settings</Text>
            </View>
          </View>
        </View>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  settingsOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    zIndex: 100,
    backgroundColor: '#00000077',
  },
  settings: {
    backgroundColor: Globals.colors.rowBackgroundGrey,
    paddingTop: 64,
  },
  settingsRow: {
    flexDirection: 'row',
    alignItems: 'center',
    height: 48,
  },
  settingsInnerRow: {
    flex: 1,
    alignSelf: 'stretch',
    justifyContent: 'center',
    borderBottomWidth: 0.5,
    borderBottomColor: '#ccc',
  },
  settingsIcon: {
    width: 44,
    height: 44,
    tintColor: Globals.colors.tintGrey,
  },
});
