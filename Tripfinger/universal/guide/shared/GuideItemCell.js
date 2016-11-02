import React from 'react';
import ReactNative from 'react-native';
import FileSystem from 'react-native-filesystem';
import Globals from '../../shared/Globals';
import AutoHeightWebView from '../../shared/components/AutoHeightWebView';
import DownloadButton from './DownloadButton';
import LocalDatabaseService from '../../shared/offline/LocalDatabaseService';

const Dimensions = ReactNative.Dimensions;
const Image = ReactNative.Image;
const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;
const TouchableHighlight = ReactNative.TouchableHighlight;
const View = ReactNative.View;

export default class GuideItemCell extends React.Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    onDownloadButtonPress: React.PropTypes.func,
    initialExpand: React.PropTypes.bool,
    expandRegion: React.PropTypes.func,
    guideItem: Globals.propTypes.guideItem,
  };

  // noinspection JSUnusedGlobalSymbols
  static defaultProps = {
    initialExpand: false,
  };

  constructor(props) {
    super(props);
    this.state = {
      expanded: this.props.initialExpand,
    };
  }

  _renderReadMoreButton() {
    if (this.state.expanded) {
      return null;
    }
    return (
      <TouchableHighlight
        style={styles.button}
        onPress={() => {
          this.setState({
            expanded: true,
          });
          if (this.props.expandRegion) {
            this.props.expandRegion();
          }
        }}
        underlayColor="#FFFFFF"
      >
        <Text style={styles.buttonText}>Read more</Text>
      </TouchableHighlight>
    );
  }

  _renderDownloadButton(inImage) {
    if (this.props.guideItem.category !== Globals.categories.country) {
      return null;
    }
    const downloadStatus = LocalDatabaseService.getDownloadStatusForId(this.props.guideItem.uuid);
    const buttonStyle = inImage ? styles.downloadButtonImage : styles.downloadButtonSeparate;
    return (
      <DownloadButton
        onPress={this.props.onDownloadButtonPress} style={buttonStyle}
        downloadStatus={downloadStatus}
      />
    );
  }

  _renderImageAndDownloadButton() {
    if (this.props.guideItem.images.length > 0) {
      const imageLocation = this.props.guideItem.images[0].url;
      let imageUrl;
      if (imageLocation.includes('/')) {
        const relativePath = `/${Globals.imageFolder}/${imageLocation}`;
        imageUrl = FileSystem.absolutePath(relativePath, FileSystem.storage.important);
      } else {
        imageUrl = `${Globals.imagesUrl}${imageLocation}-712x534`;
      }
      const height = (Dimensions.get('window').width * 0.75) - 50;
      return (
        <Image source={{ uri: imageUrl }} style={{ height }}>
          {this._renderDownloadButton(true)}
        </Image>
      );
    }
    return this._renderDownloadButton(false);
  }

  render() {
    return (
      <View style={styles.container}>
        {this._renderImageAndDownloadButton()}
        <AutoHeightWebView
          html={this.props.guideItem.description}
          style={this.state.expanded ? {} : { height: 88 }}
        />
        {this._renderReadMoreButton()}
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#fff',
  },
  button: {
    marginTop: 20,
    marginLeft: 18,
    marginBottom: 20,
  },
  buttonText: {
    fontSize: 16,
    fontWeight: '400',
    color: Globals.colors.linkBlue,
  },
  downloadButtonImage: {
    position: 'absolute',
    top: 15,
    right: 15,
  },
  downloadButtonSeparate: {
    right: 10,
    top: 10,
    marginBottom: 10,
  },
});
