// <editor-fold desc="Imports">
import React from 'react';
import ReactNative from 'react-native';

const Component = React.Component;
const PropTypes = React.PropTypes;
const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;
const TouchableHighlight = ReactNative.TouchableHighlight;
const View = ReactNative.View;
// </editor-fold>

export default class StandardCell extends Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    rowId: PropTypes.string.isRequired,
    sectionId: PropTypes.string.isRequired,
    highlightRow: PropTypes.func.isRequired,
    text: PropTypes.string.isRequired,
    onPress: PropTypes.func.isRequired,
    firstRowInSectionStyles: PropTypes.object,
  };

  // noinspection JSUnusedGlobalSymbols
  static defaultProps = {
    firstRowInSectionStyles: {},
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
        onPressIn={() => this.props.highlightRow(this.props.sectionId, this.props.rowId)}
        onPressOut={() => this.props.highlightRow(null)}
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
