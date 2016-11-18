import React from 'react';
import ReactNative from 'react-native';
import NavBar from '../NavBar';
import ModalMenu from '../shared/components/ModalMenu';
import MWMMapView from '../shared/native/MWMMapView';
import FeatureViewPopup from './feature_view/FeatureViewPopup';
import DownloadPopup from './DownloadPopup';
import LocationButton from './LocationButton';
import ZoomButtons from './ZoomButtons';
import BookmarkService from '../shared/native/BookmarkService';
import locationManager from '../shared/native/LocationManager';
import LocalDatabaseService from '../shared/offline/LocalDatabaseService';
import SearchScene from '../search/SearchScene';
import SearchBar from '../search/SearchBar';
import Utils from '../shared/Utils';

const StyleSheet = ReactNative.StyleSheet;
const View = ReactNative.View;

const SEARCH_ICON = require('../../assets/search_icon_nav.png');

export default class MapScene extends React.Component {

  static propTypes = {
    navigator: React.PropTypes.object,
    sceneProps: React.PropTypes.object,
    selected: React.PropTypes.object,
    query: React.PropTypes.string,
  };

  static title = () => 'Map';

  constructor(props) {
    super(props);
    this.state = {
      currentItem: null,
      locationState: 'not_located',
      currentMapRegion: null,
      query: this.props.query,
    };
  }

  componentDidMount() {
    locationManager.addObserver('MapScene', (location, heading) => {
      this.setState({ location, heading });
    });
    if (this.props.selected) {
      MWMMapView.selectFeature(this.props.selected);
    }
  }

  componentWillUnmount() {
    locationManager.removeObserver('MapScene');
  }

  _onMapObjectSelected = (info) => {
    if (info.tripfingerId) {
      console.log('mapobj selected');
      const listing = LocalDatabaseService.getGuideItemWithId(info.tripfingerId);
      listing.category = Utils.categoryName(listing.category);
      this.setState({ currentItem: listing });
    } else {
      this.setState({ currentItem: info });
    }
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

  _navigateToSearch = () => {
    this.setState({ query: null });
    this.props.navigator.push({
      scene: SearchScene,
      props: {
        initedFromMap: true,
        setMapQuery: query => this.setState({ query }),
        query: this.state.query,
      },
    });
  };

  _cancelSearch = () => {
    this.setState({ query: null });
  };

  _renderNavBarOrSearchBar() {
    if (this.state.query) {
      return(
        <SearchBar
          query={this.state.query} onClick={this._navigateToSearch} cancel={this._cancelSearch}
        />
    );
    } else {
      const actions = [
        { action: this._navigateToSearch, res: SEARCH_ICON },
        { action: () => this.modalMenu.toggleSettings(), res: ModalMenu.MENU_ICON },
      ];
      const { navigator, sceneProps } = this.props;
      return <NavBar navigator={navigator} sceneProps={sceneProps} actions={actions} />;
    }
  }

  // noinspection JSMethodCanBeStatic
  render() {
    return (
      <View style={styles.container}>
        {this._renderNavBarOrSearchBar()}
        <MWMMapView
          style={styles.map}
          onMapObjectSelected={this._onMapObjectSelected}
          onMapObjectDeselected={this._onMapObjectDeselected}
          onLocationStateChanged={this._onLocationStateChanged}
          onZoomedInToMapRegion={this._onZoomedInToMapRegion}
          onZoomedOutOfMapRegion={this._onZoomedOutOfMapRegion}
          location={this.state.location}
          heading={this.state.heading}
          query={this.state.query}
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
