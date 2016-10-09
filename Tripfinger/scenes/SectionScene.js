// <editor-fold desc="Imports">
import React from 'react';
import ReactNative from 'react-native';
import GuideItemCell from '../components/GuideItemCell';
import StandardCell from '../components/ListCells/StandardCell';
import ListCellSeparator from '../components/ListCells/ListCellSeparator';
import Globals from '../modules/Globals';
import { getGuideTextWithId } from '../modules/ContentService';

const Component = React.Component;
const ListView = ReactNative.ListView;
const StyleSheet = ReactNative.StyleSheet;
// </editor-fold>

export default class SectionScene extends Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    navigator: Globals.propTypes.navigator,
    section: Globals.propTypes.guideItem,
  };

  // noinspection JSUnusedGlobalSymbols
  static title = props => props.section.name;

  constructor(props) {
    super(props);
    // noinspection JSUnusedGlobalSymbols
    const ds = new ListView.DataSource({
      rowHasChanged: (r1, r2) => r1 !== r2,
      sectionHeaderHasChanged: (s1, s2) => s1 !== s2,
    });
    this.data = { guideItem: [{}] };
    this.state = {
      expanded: false,
      dataSource: ds.cloneWithRowsAndSections(this.data),
    };
    this.loadSectionIfNecessary();
  }

  async loadSectionIfNecessary() {
    if (this.props.section.loadStatus !== 'FULLY_LOADED') {
      try {
        const section = await getGuideTextWithId(this.props.section.uuid);
        // noinspection JSUnresolvedVariable
        this.data.sections = section.guideSections;
        const dataSource = this.state.dataSource.cloneWithRowsAndSections(this.data, this.sections);
        this.setState({ dataSource });
      } catch (error) {
        console.log(`loadSectionIfNecessary error: ${error}`);
        setTimeout(() => this.loadSectionIfNecessary(), 2000);
      }
    }
  }

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
      return <GuideItemCell guideItem={this.props.section} initialExpand />;
    } else if (sectionId === 'sections') {
      return (
        <StandardCell
          rowId={rowId} sectionId={sectionId} highlightRow={highlightRow}
          firstRowInSectionStyles={StyleSheet.flatten(styles.firstRowInSection)}
          onPress={() => this.navigateToSection(data)}
          text={data.name}
        />
      );
    }
    return null;
  };

  renderSeparator = (sectionId, rowId, highlighted) => (
    <ListCellSeparator key={`${sectionId}:${rowId}:sep`} highlighted={highlighted} />
  );

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
