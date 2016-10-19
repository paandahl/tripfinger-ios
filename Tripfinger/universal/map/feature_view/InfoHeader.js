import React from 'react';
import ReactNative from 'react-native';
import ViewState from './FeatureViewState';
import DistanceLabel from './DistanceLabel';

const Image = ReactNative.Image;
const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;
const TouchableHighlight = ReactNative.TouchableHighlight;
const View = ReactNative.View;
const expandImage = require('../../../assets/placepage/placepage_tip.png');
const collapseImage = require('../../../assets/placepage/placepage_collapse.png');

export default class InfoHeader extends React.Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    info: React.PropTypes.object.isRequired,
    location: React.PropTypes.object,
    onClick: React.PropTypes.func.isRequired,
    onHeaderHeightUpdate: React.PropTypes.func.isRequired,
    viewState: React.PropTypes.string.isRequired,
  };

  _renderAddress() {
    if (this.props.info.address) {
      return <Text style={styles.address}>{this.props.info.address}</Text>;
    }
    return null;
  }

  render() {
    const headerTip = this.props.viewState === ViewState.EXPANDED ? collapseImage : expandImage;
    return (
      <TouchableHighlight
        style={styles.header}
        underlayColor="#FFF"
        onPress={this.props.onClick}
        onLayout={(event) => {
          this.props.onHeaderHeightUpdate(event.nativeEvent.layout.height);
        }}
      >
        <View>
          <Image style={styles.tip} source={headerTip} />
          <Text style={styles.name}>{this.props.info.name}</Text>
          <View>
            <Text style={styles.type}>{this.props.info.category}</Text>
            <DistanceLabel info={this.props.info} location={this.props.location} />
          </View>
          {this._renderAddress()}
        </View>
      </TouchableHighlight>
    );
  }
}

const styles = StyleSheet.create({
  header: {
    paddingBottom: 18,
    alignSelf: 'stretch',
    paddingLeft: 20,
    paddingRight: 20,
  },
  tip: {
    alignSelf: 'center',
  },
  name: {
    fontSize: 21,
    fontWeight: '500',
    marginTop: 4,
    marginBottom: 6,
  },
  type: {
    color: '#777',
  },
  address: {
    color: '#777',
    marginTop: 5,
  },
});
