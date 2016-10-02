// <editor-fold desc="Imports">
import React from 'react';
import ReactNative from 'react-native';
import FSComponent from '../modules/FSComponent';

const Component = React.Component;
const PropTypes = React.PropTypes;
const ActivityIndicator = ReactNative.ActivityIndicator;
const Image = ReactNative.Image;
const View = ReactNative.View;
const Text = ReactNative.Text;
const StyleSheet = ReactNative.StyleSheet;
// </editor-fold>

export default class WorldAreaHeader extends Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    url: PropTypes.string.isRequired,
    fileName: PropTypes.string.isRequired,
    title: PropTypes.string.isRequired,
    height: PropTypes.number.isRequired,
  };

  constructor(props) {
    super(props);
    this.state = {
      localImagePath: null,
    };
  }

  componentDidMount() {
    this.loadImage(this.props.url);
  }

  componentWillReceiveProps(newProps) {
    if (newProps.url !== this.props.url) {
      this.loadImage(newProps.url);
    }
  }

  loadImage(url) {
    FSComponent.downloadFile(url, this.props.fileName, (error, filePath) => {
      this.setState({
        localImagePath: filePath,
      });
    });
  }

  renderLoader() {
    const height = { height: this.props.height };
    return (
      <View style={[styles.container, height]}>
        <ActivityIndicator />
      </View>
    );
  }

  renderImage() {
    const imageUri = `${this.state.localImagePath}`;
    return (
      <Image source={{ uri: imageUri }} style={{ height: this.props.height }}>
        <Text style={styles.title}>{this.props.title}</Text>
      </Image>
    );
  }

  render() {
    if (!this.state.localImagePath) {
      return this.renderLoader();
    }
    return this.renderImage();
  }
}

const styles = StyleSheet.create({
  container: {
    justifyContent: 'center',
  },
  title: {
    position: 'absolute',
    bottom: 10,
    left: 10,
    color: '#cccccc',
    fontWeight: 'bold',
    fontSize: 18,
    textShadowColor: '#000000',
    textShadowOffset: { width: 1, height: 1 },
    backgroundColor: '#00000000',
  },
});
