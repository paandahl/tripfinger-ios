import React from 'react';
import ReactNative from 'react-native';
import Globals from '../../../shared/Globals';
import IconCell from './IconCell';

const Linking = ReactNative.Linking;
const TouchableHighlight = ReactNative.TouchableHighlight;
const View = ReactNative.View;

export default class LinkCell extends React.Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    text: React.PropTypes.string.isRequired,
    url: React.PropTypes.string.isRequired,
    icon: React.PropTypes.any.isRequired,
  };

  _onPress = () => {
    Linking.openURL(this.props.url);
  };

  render() {
    return (
      <TouchableHighlight
        underlayColor="#DDDDDD"
        onPressIn={this.pressIn}
        onPressOut={this.pressOut}
        onPress={this._onPress}
      >
        <View>
          <IconCell
            text={this.props.text}
            icon={this.props.icon}
            iconTintColor={Globals.colors.linkBlue}
            textColor={Globals.colors.linkBlue}
          />
        </View>
      </TouchableHighlight>
    );
  }
}
