// <editor-fold desc="Imports">
import React from 'react';
import ReactNative from 'react-native';
import MWMMapView from '../components/MWMMapView';

const Component = React.Component;
const StyleSheet = ReactNative.StyleSheet;
const View = ReactNative.View;
// </editor-fold>

export default class MapScene extends Component {

  // noinspection JSMethodCanBeStatic
  render() {
    return (
      <View style={styles.container}>
        <MWMMapView style={styles.map} />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    backgroundColor: '#F5FCFF',
  },
  map: {
    flex: 1,
  },
});
