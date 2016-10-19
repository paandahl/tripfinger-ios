import React from 'react';
import ReactNative from 'react-native';
import GuideItemCell from '../shared/GuideItemCell';
import StandardCell from '../../shared/components/StandardCell';
import { getRegionWithSlug } from '../../shared/ContentService';
import SectionScene from './SectionScene';
import Globals from '../../shared/Globals';
import Utils from '../../shared/Utils';
import CategoryScene from '../listings/CategoryScene';
import ListViewContainer from '../../shared/components/ListViewContainer';

const Component = React.Component;
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
        this.data.subRegions = region.subRegions.sort((a, b) => a.name.localeCompare(b.name));
        this.data.catDescs = region.categoryDescriptions;
        const dataSource = this.state.dataSource.cloneWithRowsAndSections(this.data);
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
    const catDesc = {
      category: Globals.categories.attractions,
    };
    this.navigateToCategory(catDesc);
  };

  navigateToSubRegion = (subRegion) => {
    this.props.navigator.push({
      component: RegionScene,
      passProps: {
        region: subRegion,
      },
    });
  };

  navigateToCategory = (catDesc) => {
    this.props.navigator.push({
      component: CategoryScene,
      passProps: {
        categoryDesc: catDesc,
        region: this.props.region,
      },
    });
  };

  renderRow = (data, sectionId, isFirstRow, isLastRow) => {
    const props = { isFirstRow, isLastRow };
    if (sectionId === 'guideItem') {
      const region = this.props.region;
      return <GuideItemCell guideItem={region} expandRegion={this.expandRegion} {...props} />;
    } else if (sectionId === 'sections' && this.state.expanded) {
      const text = data.name;
      return <StandardCell onPress={() => this.navigateToSection(data)} text={text} {...props} />;
    } else if (sectionId === 'attractions') {
      return <StandardCell onPress={this.navigateToAttractions} text="Attractions" {...props} />;
    } else if (sectionId === 'subRegions') {
      const text = data.name;
      return <StandardCell onPress={() => this.navigateToSubRegion(data)} text={text} {...props} />;
    } else if (sectionId === 'catDescs') {
      const text = Utils.categoryName(data.category);
      return <StandardCell onPress={() => this.navigateToCategory(data)} text={text} {...props} />;
    }
    return null;
  };

  render() {
    return (
      <ListViewContainer
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
