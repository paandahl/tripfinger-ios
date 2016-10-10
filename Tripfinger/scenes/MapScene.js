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
      currentMapRegion: null,
    };
  }

  componentDidMount() {
    locationManager.addObserver('MapScene', (location, heading) => {
      this.setState({ location, heading });
    });
  }

  componentWillUnmount() {
    locationManager.removeObserver('MapScene');
  }

  _onMapObjectSelected = (info) => {
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

  _onMapObjectDeselected = (switchFullScreen) => {
    this.setState({ currentItem: null });
    // [self dismissPlacePage];
    //
    // auto & f = GetFramework();
    // if (switchFullScreenMode && self.controlsManager.searchHidden && !f.IsRouteNavigable())
    //   self.controlsManager.hidden = !self.controlsManager.hidden;
  };

  _onLocationStateChanged = (locationState) => {
    console.log(`new location state: ${locationState}`);
    this.setState({ locationState });
    if (locationState === 'pending') {
      locationManager.pushLocation();
    }
  };

  _onZoomedInToMapRegion = (mapRegion) => {
    console.log(`zoomed in to map region: ${JSON.stringify(mapRegion)}`);
    this.setState({ currentMapRegion: mapRegion });
  };

  _onZoomedOutOfMapRegion = () => {
    console.log('zoomed out of map region');
    this.setState({ currentMapRegion: null });
  };

  _renderDownloadPopup = () => {
    if (this.state.currentMapRegion) {
      return <DownloadPopup mapRegion={this.state.currentMapRegion} />;
    }
    return null;
  };

  // noinspection JSMethodCanBeStatic
  render() {
    return (
      <View style={styles.container}>
        <MWMMapView
          style={styles.map}
          onMapObjectSelected={this._onMapObjectSelected}
          onMapObjectDeselected={this._onMapObjectDeselected}
          onLocationStateChanged={this._onLocationStateChanged}
          onZoomedInToMapRegion={this._onZoomedInToMapRegion}
          onZoomedOutOfMapRegion={this._onZoomedOutOfMapRegion}
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
        {this._renderDownloadPopup()}
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
