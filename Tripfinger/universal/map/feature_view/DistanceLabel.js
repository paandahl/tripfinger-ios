import React from 'react';
import ReactNative from 'react-native';
import Utils from '../../shared/Utils';

const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;

export default class DistanceLabel extends React.Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    info: React.PropTypes.object.isRequired,
    location: React.PropTypes.object,
  };

  _getDistance() {
    if (this.props.location) {
      const locLat = this.props.location.coords.latitude;
      const locLon = this.props.location.coords.longitude;
      const infoLat = this.props.info.lat;
      const infoLon = this.props.info.lon;
      const distance = Utils.distanceOnEarth(locLat, locLon, infoLat, infoLon);
      return Utils.formatDistance(distance);
    }
    return '';
  }

  render() {
    return <Text style={styles.distance}>{this._getDistance()}</Text>;
  }
}

const styles = StyleSheet.create({
  distance: {
    position: 'absolute',
    top: 0,
    right: 0,
    fontWeight: '500',
    color: '#1C80EC',
  },
});
