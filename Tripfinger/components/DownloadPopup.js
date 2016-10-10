import React from 'react';
import ReactNative from 'react-native';
import Utils from '../modules/Utils';
import Globals from '../modules/Globals';

const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;
const TouchableHighlight = ReactNative.TouchableHighlight;
const View = ReactNative.View;

export default class DownloadPopup extends React.Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    style: React.PropTypes.any,
    mapRegion: React.PropTypes.object.isRequired,
  };

  _renderParentName() {
    if (this.props.mapRegion.parentName) {
      return <Text style={styles.countryName}>{this.props.mapRegion.parentName}</Text>;
    }
    return null;
  }

  render() {
    return (
      <View style={styles.box}>
        {this._renderParentName()}
        <Text style={styles.regionName}>{this.props.mapRegion.localName}</Text>
        <Text style={styles.downloadSize}>{this.props.mapRegion.downloadSize}</Text>
        <TouchableHighlight style={styles.button}>
          <Text style={styles.buttonText}>Download Map</Text>
        </TouchableHighlight>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  box: {
    position: 'absolute',
    width: 200,
    backgroundColor: '#fff',
    top: (Utils.getScreenHeight() / 2) - 75,
    left: (Utils.getScreenWidth() / 2) - 100,
    borderRadius: 10,
    shadowColor: '#aaa',
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 1,
    alignItems: 'center',
    paddingTop: 10,
  },
  countryName: {
    marginTop: 10,
    fontSize: 16,
    color: '#444',
    textAlign: 'center',
  },
  regionName: {
    marginTop: 10,
    fontSize: 20,
    textAlign: 'center',
  },
  downloadSize: {
    marginTop: 10,
    color: '#777',
  },
  button: {
    marginTop: 20,
    marginBottom: 20,
    backgroundColor: Globals.colors.tripfingerBlue,
    padding: 10,
    borderRadius: 8,
  },
  buttonText: {
    fontSize: 16,
    color: '#fff',
  },
});
