// <editor-fold desc="Imports">
import React from 'react';
import ReactNative from 'react-native';
import { getCountries } from '../modules/ContentService';
import MapScene from './MapScene';
import WorldAreaHeader from '../components/WorldAreaHeader';
import Reachability from '../modules/Reachability';
import RegionScene from './RegionScene';

const Component = React.Component;
const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;
const ListView = ReactNative.ListView;
const View = ReactNative.View;
const TouchableHighlight = ReactNative.TouchableHighlight;
const PropTypes = React.PropTypes;
// </editor-fold>

const MAP_ICON = require('../assets/maps_icon.png');
const SETTINGS_ICON = require('../assets/ic_menu.png');

const MAP_ACTION = 'mapAction';
const SETTINGS_ACTION = 'settingsAction';

export default class CountriesScene extends Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    navigator: PropTypes.shape({
      push: PropTypes.func.isRequired,
    }),
  };

  // noinspection JSUnusedGlobalSymbols
  static title() {
    return 'Countries';
  }

  static rightButtonActions() {
    return [
      { action: MAP_ACTION, res: MAP_ICON },
      { action: SETTINGS_ACTION, res: SETTINGS_ICON },
    ];
  }

  constructor(props) {
    super(props);
    // noinspection JSUnusedGlobalSymbols
    const ds = new ListView.DataSource({
      rowHasChanged: (r1, r2) => r1 !== r2,
      sectionHeaderHasChanged: (s1, s2) => s1 !== s2,
    });
    this.state = {
      displaySettings: false,
      dataSource: ds.cloneWithRowsAndSections({}),
    };
    this.loadCountryLists();
  }

  rightButtonPressed(action) {
    switch (action) {
      case MAP_ACTION:
        this.navigateToMap();
        break;
      case SETTINGS_ACTION:
        this.toggleSettings();
        break;
      default:
        throw new Error(`Unrecognized action: ${action}`);
    }
  }

  navigateToMap() {
    this.props.navigator.push({
      component: MapScene,
      title: 'Map',
    });
  }

  toggleSettings() {
    this.setState({
      displaySettings: !this.state.displaySettings,
    });
  }

  async loadCountryLists() {
    const isConnected = await Reachability.isOnline();
    if (isConnected) {
      try {
        const countries = await getCountries();
        for (const country of countries) {
          country.loadStatus = 'CHILDREN_NOT_LOADED';
        }
        this.setState({
          dataSource: this.makeCountryLists(countries),
        });
      } catch (error) {
        console.log('loadCountryLists error: ');
        console.log(error);
        setTimeout(() => this.loadCountryLists(), 2000);
      }
    }
    // countryLists = makeCountryLists(Array(DatabaseService.getCountries()))
    // updateUI()
  }

  makeCountryLists(countries) {
    const sectionSpec = [];
    const rowSpec = {};

    for (const country of countries) {
      if (!(country.worldArea in rowSpec)) {
        rowSpec[country.worldArea] = [];
        sectionSpec.push(country.worldArea);
      }
      rowSpec[country.worldArea].push(country);
    }
    sectionSpec.sort();
    return this.state.dataSource.cloneWithRowsAndSections(rowSpec, sectionSpec);
  }

  navigateToCountry(country) {
    this.props.navigator.push({
      component: RegionScene,
      passProps: {
        region: country,
      },
    });
  }

  renderRow = (country, sectionId, rowId, highlightRow) => (
    <TouchableHighlight
      key={country.uuid}
      style={styles.row}
      underlayColor="#DDDDDD"
      onPressIn={() => highlightRow(sectionId, rowId)}
      onPressOut={() => highlightRow(null)}
      onPress={() => {
        highlightRow(sectionId, rowId);
        this.navigateToCountry(country);
        setTimeout(() => highlightRow(null), 500);
      }}
    >
      <View style={styles.innerRow}>
        <Text style={styles.rowText}>{country.name}</Text>
      </View>
    </TouchableHighlight>
  );

  renderSeparator = (sectionId, rowId, highlighted) => (
    <View
      key={sectionId + rowId}
      style={highlighted ? styles.outerSeparatorHighlighted : styles.outerSeparator}
    >
      <View style={styles.innerSeparator} />
    </View>
  );

  renderSectionHeader = (sectionData, sectionId) => (
    <WorldAreaHeader
      key={sectionId}
      url={`https://storage.googleapis.com/tripfinger-images/${sectionId}.jpeg`}
      height={150}
      fileName={`${sectionId}.jpeg`}
      title={sectionId}
    />
  );

  renderSettings = () => {
    if (!this.state.displaySettings) {
      return null;
    }
    return (
      <View style={styles.settingsOverlay}>
        <View style={styles.settings} />
      </View>
    );
  };

  render() {
    return (
      <View style={styles.container}>
        {this.renderSettings()}
        <ListView
          dataSource={this.state.dataSource}
          style={styles.list}
          renderRow={this.renderRow}
          renderSeparator={this.renderSeparator}
          renderSectionHeader={this.renderSectionHeader}
        />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  list: {
    flex: 1,
    alignSelf: 'stretch',
    backgroundColor: '#EBEBF1',
  },
  row: {
    paddingLeft: 23,
    height: 50,
    backgroundColor: '#FFFFFF',
  },
  innerRow: {
    height: 50,
    justifyContent: 'center',
  },
  rowHighlight: {
    flex: 1,
  },
  rowText: {
    fontSize: 16,
  },
  outerSeparator: {
    height: 1,
    backgroundColor: '#FFFFFF',
  },
  outerSeparatorHighlighted: {
    height: 1,
    backgroundColor: '#CCCCCC',
  },
  innerSeparator: {
    height: 1,
    backgroundColor: '#CCCCCC',
    marginLeft: 23,
  },
  mapButton: {
    padding: 20,
    width: 200,
    alignSelf: 'center',
    backgroundColor: '#CCC',
  },
  mapButtonLabel: {
    fontSize: 20,
    textAlign: 'center',
  },
  settingsOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    zIndex: 100,
    backgroundColor: '#00000077',
  },
  settings: {
    backgroundColor: '#FFF',
    height: 200,
  },
});
