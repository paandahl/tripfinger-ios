import React from 'react';
import ReactNative from 'react-native';
import InfoHeader from './InfoHeader';
import FeatureTable from '../../shared/feature_view/FeatureTable';

const StyleSheet = ReactNative.StyleSheet;
const View = ReactNative.View;

export default class FeatureViewContainer extends React.Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    headerClicked: React.PropTypes.func.isRequired,
    headerHeightUpdated: React.PropTypes.func.isRequired,
    info: React.PropTypes.object,
    viewState: React.PropTypes.string.isRequired,
    panHandlers: React.PropTypes.any,
    location: React.PropTypes.object,
  };

  constructor(props) {
    super(props);
    this.featureView = <View />;
  }

  render() {
    if (this.props.info !== null) {
      this.featureView = (
        <View style={styles.info} {...this.props.panHandlers}>
          <InfoHeader
            info={this.props.info} onClick={this.props.headerClicked} location={this.props.location}
            onHeaderHeightUpdate={this.props.headerHeightUpdated} viewState={this.props.viewState}
          />
          <FeatureTable listing={this.props.info} />
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
