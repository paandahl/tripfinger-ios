import React from 'react';
import ReactNative from 'react-native';
import GuideItemCell from '../shared/GuideItemCell';
import StandardCell from '../../shared/components/StandardCell';
import { getRegionWithSlug } from '../../shared/ContentService';
import SectionScene from './SectionScene';
import Globals from '../../shared/Globals';
import Utils from '../../shared/Utils';
import CategoryScene from '../listings/CategoryScene';

const Component = React.Component;
const ListView = ReactNative.ListView;
const StyleSheet = ReactNative.StyleSheet;

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
        this.data.attractions = ['Attractions'];
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

  navigateToAttractions = () => {
    this.props.navigator.push({
      component: CategoryScene,
      passProps: {
        categoryDesc: {
          category: Globals.categories.attractions,
        },
        region: this.props.region,
      },
    });
  };

  navigateToCategory = () => {

  };

  renderRow = (data, sectionId, rowId) => {
    const key = `${sectionId}:${rowId}`;
    const isLastRow = parseInt(rowId, 10) === this.data[sectionId].length - 1;
    if (sectionId === 'guideItem') {
      return (
        <GuideItemCell key={key} guideItem={this.props.region} expandRegion={this.expandRegion} />
      );
    } else if (sectionId === 'sections' && this.state.expanded) {
      return (
        <StandardCell
          key={key} onPress={() => this.navigateToSection(data)} row={rowId} isLastRow={isLastRow}
          text={data.name}
        />
      );
    } else if (sectionId === 'attractions') {
      return (
        <StandardCell
          onPress={() => this.navigateToAttractions()}
          key={key} text="Attractions" row={rowId} isLastRow={isLastRow}
        />
      );
    }
    return null;
  };

  render() {
    return (
      <ListView
        dataSource={this.state.dataSource}
        renderRow={this.renderRow}
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
