import React from 'react';
import ReactNative from 'react-native';
import Globals from '../../modules/Globals';

const Component = React.Component;
const PropTypes = React.PropTypes;
const Image = ReactNative.Image;
const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;
const TouchableHighlight = ReactNative.TouchableHighlight;
const View = ReactNative.View;

export default class IconCell extends Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    rowId: PropTypes.string.isRequired,
    sectionId: PropTypes.string.isRequired,
    highlightRow: PropTypes.func,
    text: PropTypes.string.isRequired,
    onPress: PropTypes.func,
    firstRowInSectionStyles: PropTypes.object,
    icon: PropTypes.any,
    textStyle: PropTypes.oneOf(['normal', 'link']),
  };

  // noinspection JSUnusedGlobalSymbols
  static defaultProps = {
    firstRowInSectionStyles: {},
    textStyle: 'normal',
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
    const rowTextStyles = [styles.rowText];
    const iconStyles = [styles.icon];
    if (this.props.textStyle === 'link') {
      rowTextStyles.push(styles.link);
      iconStyles.push(styles.linkIcon);
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
        <View style={styles.container}>
          <Image style={iconStyles} source={this.props.icon} />
          <View style={styles.innerRow}>
            <Text style={rowTextStyles}>{this.props.text}</Text>
          </View>
        </View>
      </TouchableHighlight>
    );
  }
}

const styles = StyleSheet.create({
  row: {
    paddingLeft: 15,
    height: 50,
    backgroundColor: '#FFFFFF',
  },
  firstRowInSection: {
    marginTop: 20,
  },
  container: {
    alignItems: 'center',
    flexDirection: 'row',
  },
  icon: {
    tintColor: '#5D5D5D',
    marginRight: 15,
  },
  linkIcon: {
    tintColor: Globals.colors.linkBlue,
  },
  innerRow: {
    height: 50,
    flex: 1,
    justifyContent: 'center',
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  rowHighlight: {
    flex: 1,
  },
  rowText: {
    fontSize: 16,
  },
  link: {
    color: Globals.colors.linkBlue,
  },
});
