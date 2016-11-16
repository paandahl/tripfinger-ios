import React from 'react';
import ReactNative from 'react-native';
import NavBar from '../NavBar';
import MWMMapView from '../shared/native/MWMMapView';
import FeatureViewPopup from './feature_view/FeatureViewPopup';
import DownloadPopup from './DownloadPopup';
import LocationButton from './LocationButton';
import ZoomButtons from './ZoomButtons';
import BookmarkService from '../shared/native/BookmarkService';
import locationManager from '../shared/native/LocationManager';
import LocalDatabaseService from '../shared/offline/LocalDatabaseService';

const StyleSheet = ReactNative.StyleSheet;
const View = ReactNative.View;

export default class MapScene extends React.Component {

  static propTypes = {
    navigator: React.PropTypes.object,
    sceneProps: React.PropTypes.object,
  };

  static title = () => 'Map';

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
    if (info.tripfingerId) {
      const listing = LocalDatabaseService.getGuideItemWithId(info.tripfingerId);
      this.setState({ currentItem: listing });
    } else {
      this.setState({ currentItem: info });
    }
    // self.controlsManager.hidden = NO;
  };

  _onMapObjectDeselected = () => {
    console.log('setting item to null');
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
    console.log(`adding bookmark for item: ${JSON.stringify(item)}`);
    const bookmarkKey = await BookmarkService.addBookmarkForItem(item);
    this.setState({ currentItem: { ...this.state.currentItem, bookmarkKey } });
  };

  _removeBookmark = (item) => {
    BookmarkService.removeBookmarkForItem(item);
    const newCurrentItem = { ...this.state.currentItem };
    delete newCurrentItem.bookmarkKey;
    this.setState({ currentItem: newCurrentItem });
  };

  // noinspection JSMethodCanBeStatic
  render() {
    const { navigator, sceneProps } = this.props;
    return (
      <View style={styles.container}>
        <NavBar navigator={navigator} sceneProps={sceneProps} />
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
        <FeatureViewPopup
          feature={this.state.currentItem}
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
