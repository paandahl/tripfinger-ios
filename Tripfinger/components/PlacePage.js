// <editor-fold desc="Imports">
import React from 'react';
import ReactNative from 'react-native';

const Component = React.Component;
const PropTypes = React.PropTypes;
const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;
const View = ReactNative.View;
// </editor-fold>

export default class PlacePage extends Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    info: PropTypes.object.isRequired,
  };

  render() {
    return (
      <View>
        <View style={styles.info}><Text>{this.props.info.title}</Text></View>
        <View style={styles.actionBar} />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  info: {
    backgroundColor: '#FFFFFF',
  },
  actionBar: {
    backgroundColor: '#CCCCCC',
  },
});
