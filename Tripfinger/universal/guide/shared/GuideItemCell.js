import React from 'react';
import ReactNative from 'react-native';
import { imagesBaseUrl } from '../../shared/ContentService';
import Globals from '../../shared/Globals';
import AutoHeightWebView from '../../shared/components/AutoHeightWebView';

const Component = React.Component;
const PropTypes = React.PropTypes;
const Dimensions = ReactNative.Dimensions;
const Image = ReactNative.Image;
const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;
const TouchableHighlight = ReactNative.TouchableHighlight;
const View = ReactNative.View;

export default class GuideItemCell extends Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    initialExpand: PropTypes.bool,
    expandRegion: PropTypes.func,
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

  renderReadMoreButton() {
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
          this.props.expandRegion();
        }}
        underlayColor="#FFFFFF"
      >
        <Text style={styles.buttonText}>Read more</Text>
      </TouchableHighlight>
    );
  }

  renderImage = () => {
    if (this.props.guideItem.images.length > 0) {
      const imageUri = `${imagesBaseUrl()}${this.props.guideItem.images[0].url}-712x534`;
      const height = (Dimensions.get('window').width * 0.75) - 50;
      return <Image source={{ uri: imageUri }} style={{ height }} />;
    }
    return null;
  };

  render() {
    return (
      <View style={styles.container}>
        {this.renderImage()}
        <AutoHeightWebView
          html={this.props.guideItem.description}
          style={this.state.expanded ? {} : { height: 88 }}
        />
        {this.renderReadMoreButton()}
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#FFFFFF',
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
});
