import React from 'react';
import ReactNative from 'react-native';
import Globals from '../../shared/Globals';
import DownloadService from '../../shared/offline/DownloadService';
import UniqueIdentifier from '../../shared/native/UniqueIdentifier';

const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;
const TouchableHighlight = ReactNative.TouchableHighlight;
const View = ReactNative.View;

export default class DownloadScene extends React.Component {

  static title = () => 'Download';

  static propTypes = {
    country: Globals.propTypes.region.isRequired,
  };

  constructor(props) {
    super(props);
    this.state = {
      statusFetched: true,
      guideStatus: Globals.downloadStatus.notDownloaded,
      mapStatus: Globals.downloadStatus.notDownloaded,
    };
    this._loadStatus();
  }

  async _loadStatus() {}

  _downloadGuide = async () => {
    const deviceUuid = await UniqueIdentifier.getIdentifier();
    DownloadService.downloadCountry(this.props.country, deviceUuid);
  };

  _renderDownloadGuideAndMapButton() {
    if (this.state.guideStatus !== Globals.downloadStatus.notDownloaded
      || this.state.mapStatus !== Globals.downloadStatus.notDownloaded) {
      return null;
    }
    return (
      <TouchableHighlight style={[styles.button, styles.mainButton]} onPress={this._downloadGuide}>
        <View style={styles.buttonContainer}>
          <Text style={[styles.buttonText, styles.mainButtonText]}>Guide + Map</Text>
          <Text style={[styles.downloadSize, styles.mainButtonText]}>96 MB</Text>
        </View>
      </TouchableHighlight>
    );
  }

  _renderDownloadGuideButton() {
    if (this.state.guideStatus !== Globals.downloadStatus.notDownloaded) {
      return null;
    }
    return (
      <TouchableHighlight style={styles.button}>
        <View style={styles.buttonContainer}>
          <Text style={styles.buttonText}>Only guide</Text>
          <Text style={styles.downloadSize}>56 MB</Text>
        </View>
      </TouchableHighlight>
    );
  }

  _renderDownloadMapButton() {
    if (this.state.mapStatus !== Globals.downloadStatus.notDownloaded) {
      return null;
    }
    return (
      <TouchableHighlight style={styles.button}>
        <View style={styles.buttonContainer}>
          <Text style={styles.buttonText}>Only map</Text>
          <Text style={styles.downloadSize}>40 MB</Text>
        </View>
      </TouchableHighlight>
    );
  }


  render() {
    if (!this.state.statusFetched) {
      return <View style={styles.container} />;
    }
    return (
      <View style={styles.container}>
        {this._renderDownloadGuideAndMapButton()}
        {this._renderDownloadGuideButton()}
        {this._renderDownloadMapButton()}
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    marginTop: 64,
    alignItems: 'center',
    justifyContent: 'center',
    flex: 1,
  },
  buttonContainer: {
    alignItems: 'center',
  },
  mainButton: {
    backgroundColor: Globals.colors.successGreen,
    borderColor: '#4cae4c',
  },
  mainButtonText: {
    color: '#fff',
  },
  button: {
    alignItems: 'center',
    padding: 15,
    marginBottom: 20,
    width: 200,
    borderWidth: 1,
    borderRadius: 10,
  },
  buttonText: {
    fontSize: 16,
  },
  downloadSize: {
    marginTop: 10,
  },
});
