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
    onZoomedInToMapRegion: React.PropTypes.func,
    onZoomedOutOfMapRegion: React.PropTypes.func,
    location: React.PropTypes.object,
    heading: React.PropTypes.number,
    query: React.PropTypes.string,
    style: React.PropTypes.any,
  };

  static setCustomFeatures(customFeatures) {
    // noinspection JSUnresolvedFunction
    NativeMapViewManager.setCustomFeatures(customFeatures);
  }

  static setCategoryMap(categoryMap) {
    // noinspection JSUnresolvedFunction
    NativeMapViewManager.setCategoryMap(categoryMap);
  }

  static deactivateMapSelection() {
    // noinspection JSUnresolvedFunction
    NativeMapViewManager.deactivateMapSelection();
  }

  static switchToNextPositionMode() {
    // noinspection JSUnresolvedFunction
    NativeMapViewManager.switchToNextPositionMode();
  }

  static downloadMapRegion(regionId) {
    // noinspection JSUnresolvedFunction
    NativeMapViewManager.downloadMapRegion(regionId);
  }

  static cancelMapRegionDownload(regionId) {
    // noinspection JSUnresolvedFunction
    NativeMapViewManager.cancelMapRegionDownload(regionId);
  }

  static zoomIn() {
    // noinspection JSUnresolvedFunction
    NativeMapViewManager.zoomIn();
  }

  static zoomOut() {
    // noinspection JSUnresolvedFunction
    NativeMapViewManager.zoomOut();
  }

  static selectFeature(feature) {
    // noinspection JSUnresolvedFunction
    NativeMapViewManager.selectFeature(feature);
  }

  // noinspection JSMethodCanBeStatic
  componentWillUnmount() {
    MWMMapView.deactivateMapSelection();
  }

  _onMapObjectSelected = (event) => {
    if (!this.props.onMapObjectSelected) {
      return;
    }
    // noinspection JSUnresolvedVariable
    this.props.onMapObjectSelected(event.nativeEvent.feature);
  };

  _onMapObjectDeselected = (event) => {
    if (!this.props.onMapObjectDeselected) {
      return;
    }
    // noinspection JSUnresolvedVariable
    this.props.onMapObjectDeselected(event.nativeEvent.switchFullScreen);
  };

  _onLocationStateChanged = (event) => {
    if (!this.props.onLocationStateChanged) {
      return;
    }
    // noinspection JSUnresolvedVariable
    this.props.onLocationStateChanged(event.nativeEvent.locationState);
  };

  _onZoomedInToMapRegion = (event) => {
    if (!this.props.onZoomedInToMapRegion) {
      return;
    }
    // noinspection JSUnresolvedVariable
    this.props.onZoomedInToMapRegion(event.nativeEvent.mapRegion);
  };

  _onZoomedOutOfMapRegion = () => {
    if (!this.props.onZoomedOutOfMapRegion) {
      return;
    }
    // noinspection JSUnresolvedVariable
    this.props.onZoomedOutOfMapRegion();
  };

  render() {
    return (
      <NativeMapView
        onMapObjectSelected={this._onMapObjectSelected}
        onMapObjectDeselected={this._onMapObjectDeselected}
        onLocationStateChanged={this._onLocationStateChanged}
        onZoomedInToMapRegion={this._onZoomedInToMapRegion}
        onZoomedOutOfMapRegion={this._onZoomedOutOfMapRegion}
        location={this.props.location}
        heading={this.props.heading}
        query={this.props.query}
        style={this.props.style}
      />
    );
  }
}
