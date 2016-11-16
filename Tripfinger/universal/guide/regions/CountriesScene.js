import React from 'react';
import ReactNative from 'react-native';
import NavBar from '../../NavBar';
import { getCountries } from '../../shared/OnlineDatabaseService';
import MapScene from '../../map/MapScene';
import WorldAreaHeader from './WorldAreaHeader';
import StandardCell from '../../shared/components/StandardCell';
import Reachability from '../../shared/native/Reachability';
import RegionScene from './RegionScene';
import Utils from '../../shared/Utils';
import ModalMenu from '../../shared/components/ModalMenu';

const ListView = ReactNative.ListView;
const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;
const TouchableHighlight = ReactNative.TouchableHighlight;
const View = ReactNative.View;

const MAP_ICON = require('../../../assets/maps_icon.png');

export default class CountriesScene extends React.Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    navigator: React.PropTypes.object,
    sceneProps: React.PropTypes.object,
  };

  // noinspection JSUnusedGlobalSymbols
  static title = () => 'Countries';

  constructor(props) {
    super(props);
    // noinspection JSUnusedGlobalSymbols
    const ds = Utils.simpleDataSource();
    this.state = {
      dataSource: ds.cloneWithRowsAndSections({}),
    };
    this.loadCountryLists();
  }

  navigateToMap = () => {
    this.props.navigator.push({ scene: MapScene });
  };

  async loadCountryLists() {
    const isConnected = await Reachability.isOnline();
    if (isConnected) {
      try {
        const countries = await getCountries();
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
    this._data = rowSpec;
    return this.state.dataSource.cloneWithRowsAndSections(rowSpec, sectionSpec);
  }

  navigateToCountry(country) {
    this.props.navigator.push({
      scene: RegionScene,
      props: {
        region: country,
      },
    });
  }

  renderRow = (country, sectionId, rowId) => (
    <StandardCell
      key={`${sectionId}:${rowId}`} text={country.name}
      isLastRow={parseInt(rowId, 10) === this._data[sectionId].length - 1}
      onPress={() => this.navigateToCountry(country)}
    />
  );

  renderSectionHeader = (sectionData, sectionId) => {
    const escapedId = sectionId.replace(/ /g, '%20');
    return (
      <WorldAreaHeader
        key={sectionId}
        url={`https://storage.googleapis.com/tripfinger-images/${escapedId}.jpeg`}
        height={150}
        fileName={`${sectionId}.jpeg`}
        title={sectionId}
      />
    );
  };

  render() {
    const actions = [
      { action: this.navigateToMap, res: MAP_ICON },
      { action: () => this.modalMenu.toggleSettings(), res: ModalMenu.MENU_ICON },
    ];
    const { navigator, sceneProps } = this.props;
    return (
      <View style={styles.container}>
        <NavBar navigator={navigator} sceneProps={sceneProps} actions={actions} />
        <ModalMenu ref={(instance) => { this.modalMenu = instance; }} navigator={navigator} />
        <ListView
          dataSource={this.state.dataSource}
          style={styles.list}
          renderRow={this.renderRow}
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
    paddingTop: 64,
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
});
