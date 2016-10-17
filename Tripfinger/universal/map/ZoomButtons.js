import React from 'react';
import ReactNative from 'react-native';

const Image = ReactNative.Image;
const StyleSheet = ReactNative.StyleSheet;
const TouchableHighlight = ReactNative.TouchableHighlight;
const View = ReactNative.View;
const zoomInIcon = require('../../assets/zoom_in.png');
const zoomOutIcon = require('../../assets/zoom_out.png');

export default class ZoomButtons extends React.Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    style: React.PropTypes.number,
    zoomIn: React.PropTypes.func.isRequired,
    zoomOut: React.PropTypes.func.isRequired,
  };

  render() {
    return (
      <View style={this.props.style}>
        <TouchableHighlight
          style={styles.zoomInButton} underlayColor="transparent" onPress={this.props.zoomIn}
        >
          <Image source={zoomInIcon} />
        </TouchableHighlight>
        <TouchableHighlight underlayColor="transparent" onPress={this.props.zoomOut}>
          <Image source={zoomOutIcon} />
        </TouchableHighlight>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  zoomInButton: {
    marginBottom: 10,
  },
});
