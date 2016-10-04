import React from 'react';
import ReactNative from 'react-native';

const NativeMapView = ReactNative.requireNativeComponent('MWMMapView', null);

export default class MWMMapView extends React.Component {

  static propTypes = {
    onMapObjectSelected: React.PropTypes.func,
    onMapObjectDeselected: React.PropTypes.func,
    style: React.PropTypes.any,
  };

  onMapObjectSelected = (event) => {
    if (!this.props.onMapObjectSelected) {
      return;
    }
    // noinspection JSUnresolvedVariable
    this.props.onMapObjectSelected(event.nativeEvent.info);
  };

  onMapObjectDeselected = (event) => {
    if (!this.props.onMapObjectDeselected) {
      return;
    }
    // noinspection JSUnresolvedVariable
    this.props.onMapObjectDeselected(event.nativeEvent.switchFullScreen);
  };

  render() {
    return (
      <NativeMapView
        onMapObjectSelected={this.onMapObjectSelected}
        onMapObjectDeselected={this.onMapObjectDeselected}
        style={this.props.style}
      />
    );
  }
}
