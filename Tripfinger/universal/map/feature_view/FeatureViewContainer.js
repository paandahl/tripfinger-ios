import React from 'react';
import ReactNative from 'react-native';
import InfoHeader from './InfoHeader';
import FeatureTable from '../../shared/feature_view/FeatureTable';
import ListingDetails from '../../shared/feature_view/ListingDetails';

const StyleSheet = ReactNative.StyleSheet;
const View = ReactNative.View;

export default class FeatureViewContainer extends React.Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    headerClicked: React.PropTypes.func.isRequired,
    headerHeightUpdated: React.PropTypes.func.isRequired,
    feature: React.PropTypes.object,
    viewState: React.PropTypes.string.isRequired,
    panHandlers: React.PropTypes.any,
    location: React.PropTypes.object,
  };

  constructor(props) {
    super(props);
    this.featureView = <View />;
  }

  _renderListingDetails = () => {
    if (!this.props.feature.entityType) {
      return null;
    }
    return <ListingDetails listing={this.props.feature} />;
  };

  render() {
    if (this.props.feature !== null) {
      this.featureView = (
        <View style={styles.info} {...this.props.panHandlers}>
          <InfoHeader
            info={this.props.feature} onClick={this.props.headerClicked}
            location={this.props.location} onHeaderHeightUpdate={this.props.headerHeightUpdated}
            viewState={this.props.viewState}
          />
          {this._renderListingDetails()}
          <FeatureTable listing={this.props.feature} />
          <View style={styles.hiddenFooter} />
        </View>
      );
    }
    return this.featureView;
  }
}

const styles = StyleSheet.create({
  info: {
    alignItems: 'center',
    backgroundColor: '#FFFFFF',
  },
  featureDetails: {
    alignSelf: 'stretch',
    backgroundColor: '#EBEBF1',
  },
  featureList: {
    marginTop: 20,
    marginBottom: 20,
  },
  hiddenFooter: {
    height: 147, // 47pt actionbar + 100pt extra for when openinghours collapses
  },
});
