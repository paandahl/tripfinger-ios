import React from 'react';
import ReactNative from 'react-native';
import AutoHeightWebView from '../components/AutoHeightWebView';
import Utils from '../Utils';
import { imagesBaseUrl } from '../ContentService';

const Image = ReactNative.Image;
const StyleSheet = ReactNative.StyleSheet;
const View = ReactNative.View;

export default class ListingDetails extends React.Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    listing: React.PropTypes.object,
  };

  constructor(props) {
    super(props);
    this.listingDetails = <View />;
  }

  _renderImage() {
    if (this.props.listing.images.length === 0) {
      return null;
    }
    const imageUrl = `${imagesBaseUrl()}${this.props.listing.images[0].url}-712x534`;
    const imageSource = { uri: imageUrl };
    const height = (Utils.getScreenWidth() * 0.75);
    return <Image style={[styles.image, { height }]} source={imageSource} />;
  }

  /* Stores the markup in a variable for when it's used on the map popup. The content needs to
   * stay visible after being unselected, until the closing animation has finished.
   */
  render() {
    if (this.props.listing !== null) {
      this.listingDetails = (
        <View style={styles.listingDetails}>
          {this._renderImage()}
          <AutoHeightWebView html={this.props.listing.description} />
        </View>
      );
    }
    return this.listingDetails;
  }
}

const styles = StyleSheet.create({
  listingDetails: {
    alignSelf: 'stretch',
  },
  image: {
    alignSelf: 'stretch',
  },
});
