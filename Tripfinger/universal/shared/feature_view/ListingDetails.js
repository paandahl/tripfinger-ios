import React from 'react';
import ReactNative from 'react-native';
import FileSystem from 'react-native-filesystem';
import AutoHeightWebView from '../components/AutoHeightWebView';
import Utils from '../Utils';
import Globals from '../Globals';

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
    const imageLocation = this.props.listing.images[0].url;
    let imageUrl;
    if (imageLocation.includes('/')) {
      const relativePath = `/${Globals.imageFolder}/${imageLocation}`;
      imageUrl = FileSystem.absolutePath(relativePath, FileSystem.storage.important);
    } else {
      imageUrl = `${Globals.imagesUrl}${imageLocation}-712x534`;
    }

    const imageSource = { uri: imageUrl };
    const height = (Utils.getScreenWidth() * 0.75);
    return <Image style={[styles.image, { height }]} source={imageSource} />;
  }

  /* Stores the markup in a variable for when it's used on the map popup. The content needs to
   * stay visible after being unselected, until the closing animation has finished.
   */
  render() {
    if (this.props.listing !== null) {
      let html = this.props.listing.description;
      if (this.props.listing.price && this.props.listing.price !== '<p></p>') {
        html += '<h2>Price</h2>';
        html += this.props.listing.price;
      }
      if (this.props.listing.directions && this.props.listing.directions !== '<p></p>') {
        html += '<h2>Directions</h2>';
        html += this.props.listing.directions;
      }
      this.listingDetails = (
        <View style={styles.listingDetails}>
          {this._renderImage()}
          <AutoHeightWebView html={html} />
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
