import React from 'react';
import ReactNative from 'react-native';
import Globals from '../../shared/Globals';

const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;
const TouchableHighlight = ReactNative.TouchableHighlight;

function buttonText(downloadStatus) {
  switch (downloadStatus) {
    case Globals.downloadStatus.notDownloaded:
      return 'Download';
    case Globals.downloadStatus.downloading:
      return 'Downloading';
    case Globals.downloadStatus.downloaded:
      return 'Downloaded';
    default:
      throw new Error(`Unrecognized download status: ${downloadStatus}`);
  }
}

export default function DownloadButton(props) {
  return (
    <TouchableHighlight
      onPress={props.onPress}
      style={[styles.buttonContainer, props.style]}
      underlayColor="transparent"
    >
      <Text style={styles.buttonText}>{buttonText(props.downloadStatus)}</Text>
    </TouchableHighlight>
  );
}

DownloadButton.propTypes = {
  onPress: React.PropTypes.func.isRequired,
  downloadStatus: React.PropTypes.string.isRequired,
  style: React.PropTypes.any,
};

const styles = StyleSheet.create({
  buttonContainer: {
    backgroundColor: '#ffffff99',
    borderRadius: 10,
    padding: 12,
  },
  buttonText: {
    color: Globals.colors.linkBlue,
  },
});
