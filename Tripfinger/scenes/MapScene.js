import React from 'react';
import ReactNative from 'react-native';
import MWMMapView from '../components/MWMMapView';
import PlacePage from '../components/PlacePage/PlacePage';
import DownloadPopup from '../components/DownloadPopup';
import LocationButton from '../components/LocationButton';
import locationManager from '../modules/LocationManager';

const Component = React.Component;
const StyleSheet = ReactNative.StyleSheet;
const View = ReactNative.View;

export default class MapScene extends Component {

  constructor(props) {
    super(props);
    this.state = {
      currentItem: null,
      locationState: 'not_located',
    };
  }

  componentDidMount() {
    locationManager.addObserver('MapScene', (location, heading) => {
      this.setState({ location, heading });
      console.log(`New coords: ${JSON.stringify(location)}`);
    });
  }

  componentWillUnmount() {
    locationManager.removeObserver('MapScene');
  }

  onMapObjectSelected = (info) => {
    this.setState({ currentItem: info });
    // self.controlsManager.hidden = NO;
    // if (info.GetID().IsTripfinger()) {
    //   TripfingerMark mark = *info.GetID().tripfingerMark;
    //   TripfingerEntity *entity = [DataConverter markToEntity:mark];
    //   [self.controlsManager showPlacePageWithEntity:entity];
    // } else {
    //   [self.controlsManager showPlacePage:info];
    // }
  };

  onMapObjectDeselected = (switchFullScreen) => {
    this.setState({ currentItem: null });
    // [self dismissPlacePage];
    //
    // auto & f = GetFramework();
    // if (switchFullScreenMode && self.controlsManager.searchHidden && !f.IsRouteNavigable())
    //   self.controlsManager.hidden = !self.controlsManager.hidden;
  };

  onLocationStateChanged = (locationState) => {
    console.log(`new location state: ${locationState}`);
    this.setState({ locationState });
    if (locationState === 'pending') {
      locationManager.pushLocation();
    }
  };

  // noinspection JSMethodCanBeStatic
  render() {
    return (
      <View style={styles.container}>
        <MWMMapView
          style={styles.map}
          onMapObjectSelected={this.onMapObjectSelected}
          onMapObjectDeselected={this.onMapObjectDeselected}
          onLocationStateChanged={this.onLocationStateChanged}
          location={this.state.location}
          heading={this.state.heading}
        />
        <LocationButton
          style={StyleSheet.flatten(styles.locationButton)}
          state={this.state.locationState}
          onPress={() => {
            MWMMapView.switchToNextPositionMode();
          }}
        />
        <DownloadPopup />
        <PlacePage info={this.state.currentItem} />
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
  locationButton: {
    position: 'absolute',
    bottom: 170,
    right: 10,
  },
  map: {
    flex: 1,
  },
});
