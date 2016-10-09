import React from 'react';
import ReactNative from 'react-native';
import Utils from '../modules/Utils';

const Component = React.Component;
const PropTypes = React.PropTypes;
const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;
const TouchableHighlight = ReactNative.TouchableHighlight;
const View = ReactNative.View;

export default class DownloadPopup extends Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    style: PropTypes.any,
  };

  render() {
    return (
      <View style={styles.box}>
        <Text>Download Georgia</Text>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  box: {
    position: 'absolute',
    height: 200,
    width: 300,
    top: Utils.getScreenHeight() - 100,
    left: Utils.getScreenWidth() - 150,
  },
});
