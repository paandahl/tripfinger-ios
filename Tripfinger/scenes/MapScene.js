// <editor-fold desc="Imports">
import React from 'react';
import ReactNative from 'react-native';
import MWMMapView from '../components/MWMMapView';

const Component = React.Component;
const StyleSheet = ReactNative.StyleSheet;
const View = ReactNative.View;
// </editor-fold>

export default class MapScene extends Component {

  onMapObjectSelected = (switchFullScreen) => {
    console.log('Objektet vart da selektert.');
    console.log(switchFullScreen);
    // self.controlsManager.hidden = NO;
    // if (info.GetID().IsTripfinger()) {
    //   TripfingerMark mark = *info.GetID().tripfingerMark;
    //   TripfingerEntity *entity = [DataConverter markToEntity:mark];
    //   [self.controlsManager showPlacePageWithEntity:entity];
    // } else {
    //   [self.controlsManager showPlacePage:info];
    // }
  };

  onMapObjectDeselected = (info) => {
    console.log('Objektet vart da avselektert.');
    console.log(info);
    // [self dismissPlacePage];
    //
    // auto & f = GetFramework();
    // if (switchFullScreenMode && self.controlsManager.searchHidden && !f.IsRouteNavigable())
    //   self.controlsManager.hidden = !self.controlsManager.hidden;
  };

  // noinspection JSMethodCanBeStatic
  render() {
    return (
      <View style={styles.container}>
        <MWMMapView
          style={styles.map}
          onMapObjectSelected={this.onMapObjectSelected}
          onMapObjectDeselected={this.onMapObjectDeselected}
        />
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
