import React from 'react';
import ReactNative from 'react-native';
import { imagesBaseUrl } from '../../shared/ContentService';

const Image = ReactNative.Image;
const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;
const TouchableHighlight = ReactNative.TouchableHighlight;
const View = ReactNative.View;

export default class ListingCell extends React.Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    listing: React.PropTypes.object.isRequired,
    onPress: React.PropTypes.func,
    isFirstRow: React.PropTypes.bool,
    isLastRow: React.PropTypes.bool,
  };

  _renderInnerView() {
    return (
      <View style={styles.textContainer}>
        <Text style={styles.rowText}>{this.props.listing.name}</Text>
      </View>
    );
  }

  _renderContainer() {
    if (this.props.listing.images.length > 0) {
      const imageUrl = `${imagesBaseUrl()}${this.props.listing.images[0].url}-712x534`;
      const imageSource = { uri: imageUrl };
      return <Image style={styles.image} source={imageSource}>{this._renderInnerView()}</Image>;
    }
    return <View style={styles.container}>{this._renderInnerView()}</View>;
  }

  render() {
    const rowStyles = [styles.row];
    if (this.props.isFirstRow) {
      rowStyles.push(styles.firstRowInSection);
    }
    if (this.props.isLastRow) {
      rowStyles.push(styles.lastRowInSection);
    }
    return (
      <TouchableHighlight
        style={rowStyles}
        underlayColor="transparent"
        onPress={this.props.onPress}
      >
        {this._renderContainer()}
      </TouchableHighlight>
    );
  }
}

const styles = StyleSheet.create({
  row: {
    backgroundColor: '#FFFFFF',
    borderBottomWidth: 4,
    borderBottomColor: '#ddd',
  },
  image: {
    height: 200,
  },
  container: {
    height: 80,
  },
  firstRowInSection: {
    marginTop: 20,
  },
  lastRowInSection: {
    borderBottomWidth: 0.5,
    borderBottomColor: '#ccc',
  },
  innerRow: {
    flex: 1,
    borderBottomWidth: 0.5,
    borderBottomColor: '#ccc',
  },
  rowHighlight: {
    flex: 1,
  },
  textContainer: {
    position: 'absolute',
    bottom: 15,
    left: 23,
    backgroundColor: '#ffffff99',
    padding: 5,
    borderRadius: 5,
  },
  rowText: {
    fontSize: 16,
  },
});
