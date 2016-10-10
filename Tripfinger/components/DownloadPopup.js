import CircleSnail from 'react-native-progress/CircleSnail';
import ProgressCircle from 'react-native-progress/Circle';
import React from 'react';
import ReactNative from 'react-native';
import Utils from '../modules/Utils';
import Globals from '../modules/Globals';

const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;
const TouchableHighlight = ReactNative.TouchableHighlight;
const View = ReactNative.View;


export default class DownloadPopup extends React.Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    style: React.PropTypes.any,
    mapRegion: React.PropTypes.shape({
      mapRegionId: React.PropTypes.string.isRequired,
      localName: React.PropTypes.string.isRequired,
      status: React.PropTypes.string.isRequired,
      downloadSize: React.PropTypes.string.isRequired,
      parentName: React.PropTypes.string,
      progress: React.PropTypes.number,
      size: React.PropTypes.number,
    }),
    downloadMap: React.PropTypes.func.isRequired,
    cancelMapDownload: React.PropTypes.func.isRequired,
  };

  _renderParentName() {
    if (this.props.mapRegion.parentName) {
      return <Text style={styles.countryName}>{this.props.mapRegion.parentName}</Text>;
    }
    return null;
  }

  _renderCancelButton() {
    return (
      <TouchableHighlight
        style={[styles.button, styles.cancelButton]}
        onPress={() => this.props.cancelMapDownload(this.props.mapRegion.mapRegionId)}
      >
        <Text style={styles.buttonText}>Cancel</Text>
      </TouchableHighlight>
    );
  }

  _renderButtonOrProgress() {
    if (this.props.mapRegion.status === 'in_queue') {
      return (
        <View style={styles.progressContainer}>
          <Text style={styles.progressHeading}>In queue:</Text>
          <CircleSnail />
          {this._renderCancelButton()}
        </View>
      );
    } else if (this.props.mapRegion.status === 'downloading') {
      const progress = this.props.mapRegion.progress / this.props.mapRegion.size;
      let progressView = <CircleSnail />;
      if (progress > 0) {
        progressView = <ProgressCircle progress={progress} showsText thickness={6} />;
      }
      return (
        <View style={styles.progressContainer}>
          <Text style={styles.progressHeading}>Downloading:</Text>
          {progressView}
          {this._renderCancelButton()}
        </View>
      );
    }
    return (
      <TouchableHighlight
        style={[styles.button, styles.downloadButton]}
        onPress={() => this.props.downloadMap(this.props.mapRegion.mapRegionId)}
      >
        <Text style={styles.buttonText}>Download Map</Text>
      </TouchableHighlight>
    );
  }

  render() {
    return (
      <View style={styles.box}>
        {this._renderParentName()}
        <Text style={styles.regionName}>{this.props.mapRegion.localName}</Text>
        <Text style={styles.downloadSize}>{this.props.mapRegion.downloadSize}</Text>
        {this._renderButtonOrProgress()}
      </View>
    );
  }
}

const styles = StyleSheet.create({
  box: {
    position: 'absolute',
    width: 200,
    backgroundColor: '#fff',
    top: (Utils.getScreenHeight() / 2) - 75,
    left: (Utils.getScreenWidth() / 2) - 100,
    borderRadius: 10,
    shadowColor: '#aaa',
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 1,
    alignItems: 'center',
    paddingTop: 10,
  },
  countryName: {
    marginTop: 10,
    fontSize: 16,
    color: '#444',
    textAlign: 'center',
  },
  regionName: {
    marginTop: 10,
    fontSize: 20,
    textAlign: 'center',
  },
  downloadSize: {
    marginTop: 10,
    color: '#777',
  },
  button: {
    marginTop: 20,
    marginBottom: 20,
    padding: 10,
    borderRadius: 8,
  },
  buttonText: {
    fontSize: 16,
    color: '#fff',
  },
  downloadButton: {
    backgroundColor: Globals.colors.tripfingerBlue,
  },
  cancelButton: {
    backgroundColor: Globals.colors.cancelRed,
  },

  progressContainer: {
    marginTop: 10,
    alignItems: 'center',
  },
  progressHeading: {
    color: '#666',
    marginBottom: 10,
  },
});
