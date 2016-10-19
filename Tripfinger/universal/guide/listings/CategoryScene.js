import React from 'react';
import ReactNative from 'react-native';
import { SegmentedControls } from 'react-native-radio-buttons';
import Globals from '../../shared/Globals';
import Utils from '../../shared/Utils';
import ListingsList from './ListingsList';

const View = ReactNative.View;
const StyleSheet = ReactNative.StyleSheet;

export default class CategoryScene extends React.Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    navigator: Globals.propTypes.navigator.isRequired,
    categoryDesc: React.PropTypes.object.isRequired,
    region: Globals.propTypes.guideItem.isRequired,
  };

  // noinspection JSUnusedGlobalSymbols
  static title = props => Utils.categoryName(props.categoryDesc.category);

  constructor(props) {
    super(props);
    const isAttractions = this.props.categoryDesc.category === Globals.categories.attractions;
    this.state = {
      selectedOption: isAttractions ? 'Swipe' : 'List',
    };
  }

  _renderContent = () => {
    if (this.state.selectedOption === 'List') {
      return (
        <ListingsList
          categoryDesc={this.props.categoryDesc} region={this.props.region}
          navigator={this.props.navigator}
        />
      );
    }
    return null;
  };

  _renderHeader() {
    if (this.props.categoryDesc.category !== Globals.categories.attractions) {
      return null;
    }
    return (
      <SegmentedControls
        options={['Swipe', 'List']}
        selectedOption={this.state.selectedOption}
        onSelection={opt => this.setState({ selectedOption: opt })}
        tint={'#555'}
        selectedTint={'#fff'}
        backTint={'#fff'}
        paddingTop={8}
        paddingBottom={8}
      />
    );
  }

  render() {
    return (
      <View style={styles.container}>
        <View style={styles.segmented}>
          {this._renderHeader()}
        </View>
        <View style={styles.subContainer}>
          {this._renderContent()}
        </View>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    marginTop: 80,
    alignItems: 'center',
    flex: 1,
  },
  segmented: {
    width: 200,
    paddingBottom: 20,
  },
  subContainer: {
    flex: 1,
    alignSelf: 'stretch',
  },
});
