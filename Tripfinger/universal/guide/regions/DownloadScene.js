import React from 'react';
import ReactNative from 'react-native';
import Button from '../../shared/components/Button';
import Globals from '../../shared/Globals';
import DownloadService from '../../shared/offline/DownloadService';
import UniqueIdentifier from '../../shared/native/UniqueIdentifier';
import LocalDatabaseService from '../../shared/offline/LocalDatabaseService';

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
      statusFetched: false,
      guideStatus: Globals.downloadStatus.notDownloaded,
      mapStatus: Globals.downloadStatus.notDownloaded,
    };
  }

  componentDidMount() {
    this._loadStatus();
  }

  async _loadStatus() {
    const guideStatus = LocalDatabaseService.getDownloadStatusForId(this.props.country.uuid);
    const mapStatus = Globals.downloadStatus.notDownloaded;
    this.setState({ guideStatus, mapStatus, statusFetched: true });
  }

  _downloadGuide = async () => {
    const deviceUuid = await UniqueIdentifier.getIdentifier();
    await DownloadService.downloadCountry(this.props.country, deviceUuid);
    this._loadStatus();
  };

  _deleteGuide = async () => {
    await DownloadService.deleteCountry(this.props.country);
    this._loadStatus();
  };

  _renderDeleteGuideButton() {
    if (this.state.guideStatus !== Globals.downloadStatus.downloaded) {
      return null;
    }
    return (
      <Button style={styles.deleteBtn} onPress={this._deleteGuide}>
        <Text style={styles.buttonText}>Dete guide</Text>
        <Text style={styles.downloadSize}>56 MB</Text>
      </Button>
    );
  }

  _renderDownloadGuideAndMapButton() {
    if (this.state.guideStatus !== Globals.downloadStatus.notDownloaded
      || this.state.mapStatus !== Globals.downloadStatus.notDownloaded) {
      return null;
    }
    return (
      <Button style={styles.mainButton} onPress={this._downloadGuide}>
        <Text style={styles.buttonText}>Guide + Map</Text>
        <Text style={styles.downloadSize}>96 MB</Text>
      </Button>
    );
  }

  _renderDownloadGuideButton() {
    if (this.state.guideStatus !== Globals.downloadStatus.notDownloaded) {
      return null;
    }
    const buttonText =
      this.state.mapStatus === Globals.downloadStatus.downloaded ? 'Download guide' : 'Only guide';
    return (
      <Button onPress={this._downloadGuide}>
        <Text style={styles.buttonText}>{buttonText}</Text>
        <Text style={styles.downloadSize}>56 MB</Text>
      </Button>
    );
  }

  _renderDownloadMapButton() {
    if (this.state.mapStatus !== Globals.downloadStatus.notDownloaded) {
      return null;
    }
    const buttonText =
      this.state.guideStatus === Globals.downloadStatus.downloaded ? 'Download map' : 'Only map';
    return (
      <Button onPress={this._downloadMap}>
        <Text style={styles.buttonText}>{buttonText}</Text>
        <Text style={styles.downloadSize}>40 MB</Text>
      </Button>
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
        {this._renderDeleteGuideButton()}
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
  mainButton: {
    backgroundColor: Globals.colors.successGreen,
    borderColor: '#4cae4c',
  },
  deleteBtn: {
    backgroundColor: Globals.colors.cancelRed,
  },
  mainButtonText: {
    color: '#fff',
  },
  buttonText: {
    fontSize: 16,
  },
  downloadSize: {
    marginTop: 10,
  },
});
