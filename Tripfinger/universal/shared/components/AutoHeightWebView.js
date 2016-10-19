import React from 'react';
import ReactNative from 'react-native';

const StyleSheet = ReactNative.StyleSheet;
const View = ReactNative.View;
const WebView = ReactNative.WebView;

// noinspection CssUnusedSymbol
const styleBlock = `
<style>
body, html, #height-wrapper {
    font: -apple-system-body;
    margin: 0;
    padding: 0;
}
#height-wrapper {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
}
</style>
<script>
(function() {
var wrapper = document.createElement("div");
wrapper.id = "height-wrapper";
while (document.body.firstChild) {
    wrapper.appendChild(document.body.firstChild);
}

document.body.appendChild(wrapper);

var i = 0;
function updateHeight() {
    document.title = wrapper.clientHeight;
    window.location.hash = ++i;
}
updateHeight();

window.addEventListener("load", function() {
    updateHeight();
    setTimeout(updateHeight, 1000);
});

window.addEventListener("resize", updateHeight);
}());
</script>
`;

const codeInject = html => html + styleBlock;

/**
 * Wrapped Webview which automatically sets the height according to the
 * content. Scrolling is always disabled. Required when the Webview is embedded
 * into a ScrollView with other components.
 *
 * Inspired by this SO answer http://stackoverflow.com/a/33012545
 * */
export default class AutoHeightWebView extends React.Component {

  static propTypes = {
    html: React.PropTypes.object.isRequired,
    minHeight: React.PropTypes.number,
    style: React.PropTypes.any,
  };

  // noinspection JSUnusedGlobalSymbols
  static defaultProps = {
    minHeight: 100,
  };

  constructor(props) {
    super(props);
    this.state = {
      realContentHeight: this.props.minHeight,
    };
  }

  handleNavigationChange = (navState) => {
    if (navState.title) {
      const realContentHeight = parseInt(navState.title, 10) || 0; // turn NaN to 0
      this.setState({ realContentHeight });
    }
  };

  render() {
    const { html, style, minHeight, ...otherProps } = this.props;

    if (!html) {
      throw new Error('WebViewAutoHeight supports only source.html');
    }

    const heightStyle = { height: Math.max(this.state.realContentHeight, minHeight) };
    return (
      <View>
        <WebView
          {...otherProps}
          source={{ html: codeInject(html) }}
          scrollEnabled={false}
          style={[heightStyle, styles.webview, style]}
          javaScriptEnabled
          onNavigationStateChange={this.handleNavigationChange}
        />
      </View>
    );
  }
}
const styles = StyleSheet.create({
  webview: {
    marginTop: 20,
    marginLeft: 18,
    marginRight: 10,
  },
});
