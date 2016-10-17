import React from 'react';
import ReactNative from 'react-native';
import Globals from '../../../shared/Globals';

const Image = ReactNative.Image;
const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;
const View = ReactNative.View;

export default class IconCell extends React.Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    text: React.PropTypes.string.isRequired,
    icon: React.PropTypes.any.isRequired,
    textColor: React.PropTypes.string,
    iconTintColor: React.PropTypes.string,
  };

  // noinspection JSUnusedGlobalSymbols
  static defaultProps = {
    textColor: '#000',
    iconTintColor: '#5D5D5D',
  };

  render() {
    const rowTextStyles = [{ color: this.props.textColor }, styles.rowText];
    const iconStyles = [{ tintColor: this.props.iconTintColor }, styles.icon];
    return (
      <View style={styles.row}>
        <View style={styles.container}>
          <Image style={iconStyles} source={this.props.icon} />
          <View style={styles.innerRow}>
            <Text style={rowTextStyles}>{this.props.text}</Text>
          </View>
        </View>
      </View>
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
