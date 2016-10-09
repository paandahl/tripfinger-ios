// <editor-fold desc="Imports">
import React from 'react';
import ReactNative from 'react-native';
import GuideItemCell from '../components/GuideItemCell';
import StandardCell from '../components/ListCells/StandardCell';
import ListCellSeparator from '../components/ListCells/ListCellSeparator';
import { getRegionWithSlug } from '../modules/ContentService';
import SectionScene from './SectionScene';
import Globals from '../modules/Globals';
import Utils from '../modules/Utils';

const Component = React.Component;
const ListView = ReactNative.ListView;
const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;
// </editor-fold>

export default class RegionScene extends Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    navigator: Globals.propTypes.navigator,
    region: Globals.propTypes.guideItem,
  };

  // noinspection JSUnusedGlobalSymbols
  static title = props => props.region.name;

  constructor(props) {
    super(props);
    // noinspection JSUnusedGlobalSymbols
    const ds = Utils.simpleDataSource();
    this.data = { guideItem: [{}] };
    this.state = {
      expanded: false,
      dataSource: ds.cloneWithRowsAndSections(this.data),
    };
    this.loadRegionIfNecessary();
  }

  async loadRegionIfNecessary() {
    if (this.props.region.loadStatus !== 'FULLY_LOADED') {
      try {
        const region = await getRegionWithSlug(this.props.region.slug);
        // noinspection JSUnresolvedVariable
        this.data.sections = region.guideSections;
        const dataSource = this.state.dataSource.cloneWithRowsAndSections(this.data, this.sections);
        this.setState({ dataSource });
      } catch (error) {
        console.log(`loadRegionIfNecessary error: ${error}`);
        setTimeout(() => this.loadRegionIfNecessary(), 2000);
      }
    }
  }

  expandRegion = () => {
    this.setState({ expanded: true });
  };

  navigateToSection = (section) => {
    this.props.navigator.push({
      component: SectionScene,
      passProps: {
        section,
      },
    });
  };

  renderRow = (data, sectionId, rowId, highlightRow) => {
    if (sectionId === 'guideItem') {
      return <GuideItemCell guideItem={this.props.region} expandRegion={this.expandRegion} />;
    } else if (sectionId === 'sections' && this.state.expanded) {
      return (
        <StandardCell
          rowId={rowId} sectionId={sectionId} highlightRow={highlightRow}
          firstRowInSectionStyles={StyleSheet.flatten(styles.firstRowInSection)}
          onPress={() => this.navigateToSection(data)}
          text={data.name}
        />
      );
    } else if (sectionId === 'attractions') {
      return <Text>{data}</Text>;
    }
    return null;
  };

  renderSeparator = (sectionId, rowId, highlighted) => {
    if (sectionId === 'sections' && !this.state.expanded) {
      return null;
    }
    return <ListCellSeparator key={`${sectionId}:${rowId}:sep`} highlighted={highlighted} />;
  };

  render() {
    return (
      <ListView
        dataSource={this.state.dataSource}
        renderRow={this.renderRow}
        renderSeparator={this.renderSeparator}
        style={styles.list}
      />
    );
  }
}

const styles = StyleSheet.create({
  list: {
    flex: 1,
    alignSelf: 'stretch',
    backgroundColor: '#EBEBF1',
  },
  firstRowInSection: {
    marginTop: 20,
  },
});
