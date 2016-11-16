import React from 'react';
import ReactNative from 'react-native';
import NavBar from '../../NavBar';
import GuideItemCell from '../shared/GuideItemCell';
import StandardCell from '../../shared/components/StandardCell';
import Globals from '../../shared/Globals';
import Utils from '../../shared/Utils';
import { getGuideTextWithId } from '../../shared/OnlineDatabaseService';

const ListView = ReactNative.ListView;
const StyleSheet = ReactNative.StyleSheet;
const View = ReactNative.View;

export default class SectionScene extends React.Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    navigator: React.PropTypes.object,
    sceneProps: React.PropTypes.object,
    section: Globals.propTypes.guideItem,
  };

  // noinspection JSUnusedGlobalSymbols
  static title = props => props.section.name;

  constructor(props) {
    super(props);
    const ds = Utils.simpleDataSource();
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

  render() {
    return (
      <View style={styles.container}>
        <NavBar navigator={this.props.navigator} sceneProps={this.props.sceneProps} />
        <ListView
          dataSource={this.state.dataSource}
          renderRow={this.renderRow}
          style={styles.list}
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
  firstRowInSection: {
    marginTop: 20,
  },
});
