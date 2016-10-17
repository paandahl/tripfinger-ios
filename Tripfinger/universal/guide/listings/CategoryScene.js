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
    categoryDesc: React.PropTypes.object.isRequired,
    region: Globals.propTypes.guideItem.isRequired,
  };

  // noinspection JSUnusedGlobalSymbols
  static title = props => Utils.categoryName(props.categoryDesc.category);

  constructor(props) {
    super(props);
    this.state = {
      selectedOption: 'Swipe',
    };
  }

  _renderContent = () => {
    if (this.state.selectedOption === 'List') {
      return <ListingsList categoryDesc={this.props.categoryDesc} region={this.props.region} />;
    }
    return null;
  };

  render() {
    return (
      <View style={styles.container}>
        <View style={styles.segmented}>
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
