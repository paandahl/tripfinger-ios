import React from 'react';
import ReactNative from 'react-native';
import Globals from '../shared/Globals';

const Image = ReactNative.Image;
const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;
const TextInput = ReactNative.TextInput;
const TouchableOpacity = ReactNative.TouchableOpacity;
const View = ReactNative.View;

const SEARCH_ICON = require('../../assets/search_icon.png');

export default class SearchBar extends React.Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    query: React.PropTypes.string.isRequired,
    onClick: React.PropTypes.func.isRequired,
    cancel: React.PropTypes.func.isRequired,
  };

  render() {
    return (
      <View style={styles.container}>
        <TouchableOpacity style={styles.queryContainer} onPress={this.props.onClick}>
          <TextInput style={styles.query} editable={false} value={this.props.query} />
        </TouchableOpacity>
        <Image source={SEARCH_ICON} style={styles.searchIcon} />
        <TouchableOpacity style={styles.cancelButton} onPress={this.props.cancel}>
          <Text>Cancel</Text>
        </TouchableOpacity>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    padding: 10,
    paddingTop: 25,
    paddingBottom: 5,
    height: 64,
    backgroundColor: Globals.colors.tripfingerBlue,
    justifyContent: 'center',
    flexDirection: 'row',
  },
  queryContainer: {
    flex: 1,
  },
  query: {
    borderRadius: 4,
    height: 34,
    padding: 10,
    paddingLeft: 40,
    backgroundColor: '#fff',
  },
  searchIcon: {
    tintColor: '#777',
    position: 'absolute',
    left: 15,
    top: 25,
    height: 32,
    width: 32,
  },
  cancelButton: {
    marginLeft: 10,
    justifyContent: 'center',
  },
});
