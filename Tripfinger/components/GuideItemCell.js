// <editor-fold desc="Imports">
import React from 'react';
import ReactNative from 'react-native';
import { imagesBaseUrl } from '../modules/ContentService';

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
    region: PropTypes.shape({
      description: PropTypes.string.isRequired,
      images: PropTypes.array.isRequired,
    }),
  };

  constructor(props) {
    super(props);
    this.state = {
      webViewHeight: 80,
    };
  }

  updateWebViewHeight = (event) => {
    // jsEvaluationValue contains result of injected JS
    // noinspection JSUnresolvedVariable
    const htmlHeight = parseInt(event.jsEvaluationValue, 10);
    console.log(`htmlHeight: ${htmlHeight}`);
    // this.setState({ webViewHeight: htmlHeight });
  };

  render() {
    const html = htmlStyle + this.props.region.description;
    const imageUri = `${imagesBaseUrl()}${this.props.region.images[0].url}-712x534`;
    const height = (Dimensions.get('window').width * 0.75) - 50;
    return (
      <View style={styles.container}>
        <Image source={{ uri: imageUri }} style={{ height }} />
        <WebView
          source={{ html }}
          injectedJavaScript="document.body.scrollHeight;"
          onNavigationStateChange={this.updateWebViewHeight}
          style={[
            styles.text,
            { height: this.state.webViewHeight },
          ]}
        />
        <TouchableHighlight style={styles.button} onPress={() => {}} underlayColor="#FFFFFF">
          <Text style={styles.buttonText}>Read more</Text>
        </TouchableHighlight>
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
    color: '#3586FF',
  },
});
