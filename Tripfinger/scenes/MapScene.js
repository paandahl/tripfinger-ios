import React from 'react';
import ReactNative from 'react-native';
import MWMMapView from '../components/MWMMapView';
import PlacePage from '../components/PlacePage/PlacePage';
import DownloadPopup from '../components/DownloadPopup';
import LocationButton from '../components/LocationButton';
import ZoomButtons from '../components/ZoomButtons';
import BookmarkService from '../modules/BookmarkService';
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
    console.log(`object selected: ${JSON.stringify(info)}`);
    this.setState({ currentItem: info });
    // self.controlsManager.hidden = NO;
  };

  _onMapObjectDeselected = () => {
    this.setState({ currentItem: null });
    // auto & f = GetFramework();
    // if (switchFullScreenMode && self.controlsManager.searchHidden && !f.IsRouteNavigable())
    //   self.controlsManager.hidden = !self.controlsManager.hidden;
  };

  _onLocationStateChanged = (locationState) => {
    this.setState({ locationState });
    if (locationState === 'pending') {
      locationManager.pushLocation();
    }
  };

  _onZoomedInToMapRegion = (mapRegion) => {
    this.setState({ currentMapRegion: mapRegion });
  };

  _onZoomedOutOfMapRegion = () => {
    this.setState({ currentMapRegion: null });
  };

  _renderDownloadPopup = () => {
    if (this.state.currentMapRegion) {
      return (
        <DownloadPopup
          mapRegion={this.state.currentMapRegion}
          downloadMap={MWMMapView.downloadMapRegion}
          cancelMapDownload={MWMMapView.cancelMapRegionDownload}
        />
      );
    }
    return null;
  };

  _addBookmark = async (item) => {
    const bookmarkKey = await BookmarkService.addBookmarkForItem(item);
    this.setState({ currentItem: { ...this.state.currentItem, bookmarkKey } });
  };

  _removeBookmark = (item) => {
    console.log('removing bookmark');
    BookmarkService.removeBookmarkForItem(item);
    const newCurrentItem = { ...this.state.currentItem };
    delete newCurrentItem.bookmarkKey;
    this.setState({ currentItem: newCurrentItem });
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
        <ZoomButtons
          zoomIn={MWMMapView.zoomIn} zoomOut={MWMMapView.zoomOut} style={styles.zoomButtons}
        />
        <LocationButton
          style={StyleSheet.flatten(styles.locationButton)}
          state={this.state.locationState}
          onPress={() => {
            MWMMapView.switchToNextPositionMode();
          }}
        />
        {this._renderDownloadPopup()}
        <PlacePage
          info={this.state.currentItem}
          location={this.state.location}
          onDismiss={() => this.setState({ currentItem: null })}
          addBookmark={this._addBookmark}
          removeBookmark={this._removeBookmark}
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
  zoomButtons: {
    position: 'absolute',
    bottom: 265,
    right: 10,
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
