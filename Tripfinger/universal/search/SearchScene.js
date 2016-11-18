import React from 'react';
import ReactNative from 'react-native';
import NavBar from '../NavBar';
import Globals from '../shared/Globals';
import Utils from '../shared/Utils';
import ListViewContainer from '../shared/components/ListViewContainer';
import StandardCell from '../shared/components/StandardCell';
import SearchResultCell from './SearchResultCell';
import MWMSearch from '../shared/native/MWMSearch';
import { getGuideItemWithId, getRegionWithSlug } from '../shared/OnlineDatabaseService';
import RegionScene from '../guide/regions/RegionScene';
import CountriesScene from '../guide/regions/CountriesScene';
import ListingScene from '../guide/listings/ListingScene';
import MapScene from '../map/MapScene';
import MWMMapView from '../shared/native/MWMMapView';

const ActivityIndicator = ReactNative.ActivityIndicator;
const Image = ReactNative.Image;
const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;
const TextInput = ReactNative.TextInput;
const TouchableOpacity = ReactNative.TouchableOpacity;
const View = ReactNative.View;

const SEARCH_ICON = require('../../assets/search_icon.png');

export default class SearchScene extends React.Component {

  static title = () => 'Search';

  static propTypes = {
    navigator: React.PropTypes.object,
    sceneProps: React.PropTypes.object,
    initedFromMap: React.PropTypes.bool,
    setMapQuery: React.PropTypes.func,
    // lastQueries: React.PropTypes.array.isRequired,
  };

  static defaultProps = {
    initedFromMap: false,
  };

  constructor(props) {
    super(props);
    const ds = Utils.simpleDataSource();
    this._initRecentSearchesAndCategories();
    this.state = {
      query: '',
      searching: false,
      dataSource: ds.cloneWithRowsAndSections(this.data),
    };
  }

  _initRecentSearchesAndCategories() {
    this.data = {
      // recentSearches: this.props.lastQueries,
      categories: [
        'Attractions',
        'Transport',
        'Food and drinks',
        'Hotels',
        'Shopping',
        'Information',
      ],
    };
  }

  async _navigateToSearchResult(result) {
    if (result.tripfingerId && !this.props.initedFromMap) {
      this._contextJumpToSearchResult(result);
    } else {
      this._navigateToSearchResultOnMap(result);
    }
  }

  _contextJumpToSearchResult = async (result) => {
    const sceneDicts = [{ scene: CountriesScene }];
    const guideItem = await getGuideItemWithId(result.tripfingerId);
    let country;
    if (guideItem.category === Globals.categories.country) {
      country = guideItem;
    } else {
      country = await getRegionWithSlug(Utils.nameToSlug(guideItem.country));
    }
    let subRegion;
    if (guideItem.category === Globals.categories.subRegion) {
      subRegion = guideItem;
    } else if (guideItem.subRegion) {
      subRegion = await getRegionWithSlug(Utils.nameToSlug(guideItem.subRegion));
    }
    let city;
    if (guideItem.category === Globals.categories.city) {
      city = guideItem;
    } else if (guideItem.city) {
      city = await getRegionWithSlug(Utils.nameToSlug(guideItem.city));
    }
    let listing;
    if (guideItem.category.toString().startsWith('2')) {
      listing = guideItem;
    }

    sceneDicts.push({
      scene: RegionScene,
      props: {
        region: country,
      },
    });
    if (subRegion) {
      sceneDicts.push({
        scene: RegionScene,
        props: {
          region: subRegion,
        },
      });
    }
    if (city) {
      console.log('pushing city');
      sceneDicts.push({
        scene: RegionScene,
        props: {
          region: city,
        },
      });
    }
    if (listing) {
      sceneDicts.push({
        scene: ListingScene,
        props: {
          listing,
        },
      });
    }
    this.props.navigator.jump(sceneDicts);
  };

  _navigateToSearchResultOnMap = (result) => {
    if (this.props.initedFromMap) {
      MWMMapView.selectFeature(result);
      this.props.navigator.pop();
    } else {
      this.props.navigator.replace({
        scene: MapScene,
        props: {
          selected: result,
        },
      });
    }
  };

  _mapSearch = (query) => {
    if (this.props.initedFromMap) {
      this.props.setMapQuery(query);
      this.props.navigator.pop();
    } else {
      this.props.navigator.replace({
        scene: MapScene,
        props: {
          query,
        },
      });
    }
  };

  _renderRow = (data, sectionId, isFirstRow, isLastRow) => {
    const props = { isFirstRow, isLastRow };
    if (sectionId === 'searchResults') {
      return <SearchResultCell onPress={() => this._navigateToSearchResult(data)} result={data} />;
    } else {
      return (
        <StandardCell
          onPress={() => this._mapSearch(data)} text={data} {...props} firstRowInSectionStyle={{}}
        />
      );
    }
  };

  _sectionTitle(sectionId) {
    switch (sectionId) {
      case 'recentSearches':
        return 'RECENT';
      case 'categories':
        return 'CATEGORIES';
      case 'searchResults':
        return 'RESULTS';
      default:
        throw new Error(`unrecognized sectionId: ${sectionId}`);
    }
  }

  _renderSectionHeader = (sectionData, sectionId) => {
    return (
      <Text style={styles.sectionHeader}>{this._sectionTitle(sectionId)}</Text>
    );
  };

  _onChangeQuery = (query) => {
    if (query.length === 0) {
      MWMSearch.cancel();
      this._initRecentSearchesAndCategories();
      this.setState({
        query,
        searching: false,
        dataSource: this.state.dataSource.cloneWithRowsAndSections(this.data),
      });
    } else {
      this.setState({
        query,
        searching: true,
      });
      MWMSearch.search(query, (results) => {
        this.data = {
          searchResults: results,
        };
        this.setState({
          searching: false,
          dataSource: this.state.dataSource.cloneWithRowsAndSections(this.data),
        });
      });
    }
  };

  _renderSearchIcon() {
    if (this.state.searching) {
      return null;
    }
    return <Image source={SEARCH_ICON} style={styles.searchIcon} />;
  }

  _cancelClick = () => {
    if (this.props.initedFromMap) {
      this.props.setMapQuery(null);
    }
    this.props.navigator.pop();
  };

  render() {
    // const dismissMode = this.state.query === '' ? 'on-drag' : 'none';
    // const scrollVeiwHeight = Utils.getScreenHeight() - 64 - 64;
    return (
      <View style={styles.container}>
        <View style={styles.header}>
          <TextInput
            style={styles.input} autoFocus autoCorrect={false}
            onChangeText={this._onChangeQuery}
          />
          {this._renderSearchIcon()}
          <ActivityIndicator
            animating={this.state.searching}
            style={styles.loadingIndicator}
          />
          <TouchableOpacity onPress={this._cancelClick} style={styles.cancelButton}>
            <Text>Cancel</Text>
          </TouchableOpacity>
        </View>
        <ListViewContainer
          automaticallyAdjustContentInsets={false}
          dataSource={this.state.dataSource}
          renderRow={this._renderRow}
          renderSectionHeader={this._renderSectionHeader}
          keyboardShouldPersistTaps
          keyboardDismissMode="on-drag"
        />
      </View>
    );
  }
}

// SearchScene.fetchData = async () => {
//   const lastQueries = await MWMSearch.lastQueries();
//   console.log(`got ${lastQueries.length} lastQueries`);
//   return { lastQueries };
// };

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    backgroundColor: Globals.colors.tripfingerBlue,
    padding: 10,
    paddingTop: 25,
    height: 64,
    flexDirection: 'row',
  },
  sectionHeader: {
    color: '#5A5A5F',
    backgroundColor: Globals.colors.rowBackgroundGrey,
    paddingLeft: 20,
    paddingTop: 20,
    padding: 5,
    marginBottom: 0,
  },
  input: {
    backgroundColor: '#fff',
    borderRadius: 4,
    height: 34,
    padding: 5,
    paddingLeft: 40,
    flex: 1,
  },
  cancelButton: {
    justifyContent: 'center',
    marginLeft: 10,
  },
  searchIcon: {
    tintColor: '#777',
    position: 'absolute',
    left: 15,
    top: 25,
    height: 32,
    width: 32,
  },
  loadingIndicator: {
    position: 'absolute',
    left: 23,
    top: 32,
  },
  list: {
    height: 100,
  },
});
