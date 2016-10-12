// <editor-fold desc="Imports">
import React from 'react';
import ReactNative from 'react-native';
import { imagesBaseUrl } from '../modules/ContentService';
import Globals from '../modules/Globals';

const Component = React.Component;
const PropTypes = React.PropTypes;
const Dimensions = ReactNative.Dimensions;
const Image = ReactNative.Image;
const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;
const TouchableHighlight = ReactNative.TouchableHighlight;
const View = ReactNative.View;
const WebView = ReactNative.WebView;
// </editor-fold>

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
      webViewHeight: 0,
    };
  }

  updateWebViewHeight = (event) => {
    // jsEvaluationValue contains result of injected JS
    // noinspection JSUnresolvedVariable
    const htmlHeight = parseInt(event.jsEvaluationValue, 10);
    console.log(`htmlHeight: ${htmlHeight}`);
    this.setState({ webViewHeight: htmlHeight });
  };

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
    const html = htmlStyle + this.props.guideItem.description;
    return (
      <View style={styles.container}>
        {this.renderImage()}
        <WebView
          source={{ html }}
          injectedJavaScript="document.body.scrollHeight;"
          onNavigationStateChange={this.updateWebViewHeight}
          style={[
            styles.text,
            { height: this.state.expanded ? this.state.webViewHeight : 80 },
          ]}
        />
        {this.renderReadMoreButton()}
      </View>
    );
  }
}

const htmlStyle = `
<style type="text/css">
  body {
    font: -apple-system-body 
  }
</style>`;

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#FFFFFF',
  },
  text: {
    marginTop: 20,
    marginLeft: 10,
    marginRight: 10,
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
