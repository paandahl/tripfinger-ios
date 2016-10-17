import React from 'react';
import ReactNative from 'react-native';

const Animated = ReactNative.Animated;
const Easing = ReactNative.Easing;
const Image = ReactNative.Image;
const TouchableHighlight = ReactNative.TouchableHighlight;
const getLocIcon = require('../../assets/location/get_location.png');
const pendingIcon = require('../../assets/location/pending.png');
const locatedICon = require('../../assets/location/located.png');
const followingIcon = require('../../assets/location/following.png');

export default class LocationButton extends React.Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    style: React.PropTypes.object,
    state: React.PropTypes.oneOf(['not_located', 'pending', 'located', 'following']).isRequired,
    onPress: React.PropTypes.func,
  };

  constructor(props) {
    super(props);
    this.state = {
      spinValue: new Animated.Value(0),
    };
  }

  componentDidMount() {
    this.startAnimating();
  }

  componentWillUnmount() {
    if (this.animation) {
      this.animation.stop();
    }
  }

  startAnimating() {
    this.state.spinValue.setValue(0);
    this.animation = Animated.timing(
      this.state.spinValue,
      {
        toValue: 1,
        duration: 1000,
        easing: Easing.linear,
      }
    );
    this.animation.start(() => {
      this.startAnimating();
    });
  }

  render() {
    if (this.props.state === 'pending') {
      const spin = this.state.spinValue.interpolate({
        inputRange: [0, 1],
        outputRange: ['0deg', '360deg'],
      });
      return (
        <Animated.Image
          style={{ ...this.props.style, transform: [{ rotate: spin }] }}
          source={pendingIcon}
        />
      );
    }
    let icon;
    if (this.props.state === 'not_located') {
      icon = getLocIcon;
    } else if (this.props.state === 'located') {
      icon = locatedICon;
    } else { // following
      icon = followingIcon;
    }
    return (
      <TouchableHighlight underlayColor="transparent" onPress={this.props.onPress}>
        <Image style={this.props.style} source={icon} />
      </TouchableHighlight>
    );
  }
}
