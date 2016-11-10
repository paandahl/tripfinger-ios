import React from 'react';
import ReactNative from 'react-native';

const Image = ReactNative.Image;
const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;
const TouchableHighlight = ReactNative.TouchableHighlight;
const View = ReactNative.View;
const addBookmarkImage = require('../../../assets/bookmark_add.png');
const removeBookmarkImage = require('../../../assets/bookmark_remove.png');
const routeImage = require('../../../assets/ic_route.png');

export default class ActionBar extends React.Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    feature: React.PropTypes.object,
    addBookmark: React.PropTypes.func.isRequired,
    removeBookmark: React.PropTypes.func.isRequired,
  };

  constructor(props) {
    super(props);
    this.actionView = <View />;
  }

  _renderBookmarkButton() {
    if (this.props.feature.bookmarkKey) {
      return (
        <TouchableHighlight
          onPress={() => this.props.removeBookmark(this.props.feature)}
          underlayColor="transparent"
        >
          <View style={styles.actionButton}>
            <Image source={removeBookmarkImage} />
            <Text style={styles.buttonText}>Delete</Text>
          </View>
        </TouchableHighlight>
      );
    }
    return (
      <TouchableHighlight
        onPress={() => this.props.addBookmark(this.props.feature)}
        underlayColor="transparent"
      >
        <View style={styles.actionButton}>
          <Image source={addBookmarkImage} style={styles.buttonIcon} />
          <Text style={styles.buttonText}>Save</Text>
        </View>
      </TouchableHighlight>
    );
  }

  // noinspection JSMethodCanBeStatic
  render() {
    if (this.props.feature !== null) {
      this.actionView = (
        <View style={styles.actionBar}>
          {this._renderBookmarkButton()}
          <TouchableHighlight onPress={() => console.log('routePressed')}>
            <View style={styles.actionButton}>
              <Image source={routeImage} style={styles.buttonIcon} />
              <Text style={styles.buttonText}>Route</Text>
            </View>
          </TouchableHighlight>
        </View>
      );
    }

    return this.actionView;
  }
}

const styles = StyleSheet.create({
  actionBar: {
    height: 47,
    backgroundColor: '#EEE',
    borderTopWidth: 1,
    borderTopColor: '#DDD',
    justifyContent: 'center',
    flexDirection: 'row',
  },
  actionButton: {
    marginTop: 2,
    width: 150,
    alignItems: 'center',
  },
  buttonIcon: {
    tintColor: '#5D5D5D',
  },
  buttonText: {
    fontSize: 11,
    color: '#777',
  },
});
