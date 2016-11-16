import React from 'react';
import ReactNative from 'react-native';
import NavBar from '../NavBar';
import Globals from '../shared/Globals';
import Utils from '../shared/Utils';
import ListViewContainer from '../shared/components/ListViewContainer';
import StandardCell from '../shared/components/StandardCell';
import SearchResultCell from './SearchResultCell';
import MWMSearch from '../shared/native/MWMSearch';

const ActivityIndicator = ReactNative.ActivityIndicator;
const Image = ReactNative.Image;
const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;
const TextInput = ReactNative.TextInput;
const TouchableHighlight = ReactNative.TouchableHighlight;
const View = ReactNative.View;

const SEARCH_ICON = require('../../assets/search_icon.png');

export default class SearchScene extends React.Component {

  static title = () => 'Search';

  static propTypes = {
    navigator: React.PropTypes.object,
    sceneProps: React.PropTypes.object,
    // lastQueries: React.PropTypes.array.isRequired,
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
        'Hotels',
        'Restaurants',
      ],
    };
  }

  _renderRow = (data, sectionId, isFirstRow, isLastRow) => {
    const props = { isFirstRow, isLastRow };
    if (sectionId === 'searchResults') {
      return <SearchResultCell result={data} />;
    } else {
      return <StandardCell onPress={() => {}} text={data} {...props} firstRowInSectionStyle={{}} />;
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

  render() {
    // const dismissMode = this.state.query === '' ? 'on-drag' : 'none';
    // const scrollVeiwHeight = Utils.getScreenHeight() - 64 - 64;
    return (
      <View style={styles.container}>
        <NavBar navigator={this.props.navigator} sceneProps={this.props.sceneProps} />
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
        </View>
        <ListViewContainer
          automaticallyAdjustContentInsets={false}
          dataSource={this.state.dataSource}
          renderRow={this._renderRow}
          renderSectionHeader={this._renderSectionHeader}
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
    marginTop: 64,
    backgroundColor: Globals.colors.tripfingerBlue,
    padding: 10,
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
    height: 44,
    padding: 5,
    paddingLeft: 40,
  },
  searchIcon: {
    tintColor: '#777',
    position: 'absolute',
    left: 15,
    top: 15,
    height: 32,
    width: 32,
  },
  loadingIndicator: {
    position: 'absolute',
    left: 23,
    top: 22,
  },
  list: {
    height: 100,
  },
});
