import React from 'react';
import ReactNative from 'react-native';

// noinspection JSUnresolvedVariable
const NativeMapViewManager = ReactNative.NativeModules.MWMMapViewManager;
const NativeMapView = ReactNative.requireNativeComponent('MWMMapView', null);

export default class MWMMapView extends React.Component {

  static propTypes = {
    onMapObjectSelected: React.PropTypes.func,
    onMapObjectDeselected: React.PropTypes.func,
    onLocationStateChanged: React.PropTypes.func,
    location: React.PropTypes.object,
    heading: React.PropTypes.number,
    style: React.PropTypes.any,
  };

  static deactivateMapSelection() {
    // noinspection JSUnresolvedFunction
    NativeMapViewManager.deactivateMapSelection();
  }

  static switchToNextPositionMode() {
    // noinspection JSUnresolvedFunction
    NativeMapViewManager.switchToNextPositionMode();
  }

  // noinspection JSMethodCanBeStatic
  componentWillUnmount() {
    MWMMapView.deactivateMapSelection();
  }

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

  onLocationStateChanged = (event) => {
    if (!this.props.onLocationStateChanged) {
      return;
    }
    // noinspection JSUnresolvedVariable
    this.props.onLocationStateChanged(event.nativeEvent.locationState);
  };

  render() {
    return (
      <NativeMapView
        onMapObjectSelected={this.onMapObjectSelected}
        onMapObjectDeselected={this.onMapObjectDeselected}
        onLocationStateChanged={this.onLocationStateChanged}
        location={this.props.location}
        heading={this.props.heading}
        style={this.props.style}
      />
    );
  }
}
