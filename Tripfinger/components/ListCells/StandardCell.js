import React from 'react';
import ReactNative from 'react-native';

const Component = React.Component;
const PropTypes = React.PropTypes;
const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;
const TouchableHighlight = ReactNative.TouchableHighlight;
const View = ReactNative.View;

export default class StandardCell extends Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    rowId: PropTypes.string.isRequired,
    sectionId: PropTypes.string.isRequired,
    highlightRow: PropTypes.func,
    text: PropTypes.string.isRequired,
    onPress: PropTypes.func,
    firstRowInSectionStyles: PropTypes.object,
  };

  // noinspection JSUnusedGlobalSymbols
  static defaultProps = {
    firstRowInSectionStyles: {},
  };

  pressIn = () => {
    if (this.props.highlightRow) {
      this.props.highlightRow(this.props.sectionId, this.props.rowId);
    }
  };

  pressOut = () => {
    if (this.props.highlightRow) {
      this.props.highlightRow(null);
    }
  };

  render() {
    const rowStyles = [styles.row];
    if (this.props.rowId === '0') {
      rowStyles.push(this.props.firstRowInSectionStyles);
    }
    return (
      <TouchableHighlight
        key={`${this.props.sectionId}:${this.props.rowId}`}
        style={rowStyles}
        underlayColor="#DDDDDD"
        onPressIn={this.pressIn}
        onPressOut={this.pressOut}
        onPress={this.props.onPress}
      >
        <View style={styles.innerRow}>
          <Text style={styles.rowText}>{this.props.text}</Text>
        </View>
      </TouchableHighlight>
    );
  }
}

const styles = StyleSheet.create({
  row: {
    paddingLeft: 23,
    height: 50,
    backgroundColor: '#FFFFFF',
  },
  firstRowInSection: {
    marginTop: 20,
  },
  innerRow: {
    height: 50,
    justifyContent: 'center',
  },
  rowHighlight: {
    flex: 1,
  },
  rowText: {
    fontSize: 16,
  },
});
