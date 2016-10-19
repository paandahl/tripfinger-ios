import React from 'react';
import ReactNative from 'react-native';

const Image = ReactNative.Image;

export default class ImageAnimation extends React.Component {

  static propTypes = {
    animationImages: React.PropTypes.array.isRequired,
    animationRepeatCount: React.PropTypes.number,
    animationDuration: React.PropTypes.number,
  };

  // noinspection JSUnusedGlobalSymbols
  static defaultProps = {
    animationRepeatCount: 0,
    animationDuration: 1000,
  };

  constructor(props) {
    super(props);
    this.state = {
      imageIndex: 0,
    };
  }

  componentDidMount() {
    this.animationRepeatCount = this.props.animationRepeatCount;
    this.intervalId = setInterval(() => {
      let imageIndex = this.state.imageIndex + 1;
      if (imageIndex >= this.props.animationImages.length) {
        imageIndex = 0;
        if (this.animationRepeatCount === 1) {
          this.clearInterval(this.intervalId);
          return;
        }
        this.animationRepeatCount -= 1;
      }
      this.setState({ imageIndex });
    }, this.props.animationDuration);
  }

  componentWillUnmount() {
    clearInterval(this.intervalId);
  }

  render() {
    return (
      <Image {...this.props} source={this.props.animationImages[this.state.imageIndex]} />
    );
  }

  // const animationImages = [
  //   pendingLoc1, pendingLoc2, pendingLoc3, pendingLoc4, pendingLoc5, pendingLoc6,
  //   pendingLoc7, pendingLoc8, pendingLoc9, pendingLoc10, pendingLoc11, pendingLoc12,
  // ];
  // return (
  //   <View style={this.props.styles}>
  //     <ImageAnimation
  //       resizeMode="stretch"
  //       animationRepeatCount={0}
  //       animationDuration={100}
  //       animationImages={animationImages}
  //       style={styles.image}
  //     />
  //   </View>
  // );

}
