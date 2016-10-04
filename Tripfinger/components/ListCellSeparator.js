// <editor-fold desc="Imports">
import React from 'react';
import ReactNative from 'react-native';

const Component = React.Component;
const PropTypes = React.PropTypes;
const StyleSheet = ReactNative.StyleSheet;
const View = ReactNative.View;
// </editor-fold>

export default class ListCellSeparator extends Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    highlighted: PropTypes.bool.isRequired,
  };

  // noinspection JSUnusedGlobalSymbols
  static defaultProps = {
    firstRowInSectionStyles: {},
  };

  render() {
    const highlighted = this.props.highlighted;
    return (
      <View
        style={highlighted ? styles.outerSeparatorHighlighted : styles.outerSeparator}
      >
        <View style={styles.innerSeparator} />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  outerSeparator: {
    height: 1,
    backgroundColor: '#FFFFFF',
  },
  outerSeparatorHighlighted: {
    height: 1,
    backgroundColor: '#CCCCCC',
  },
  innerSeparator: {
    height: 1,
    backgroundColor: '#CCCCCC',
    marginLeft: 23,
  },
});
