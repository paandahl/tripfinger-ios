import React from 'react';
import ReactNative from 'react-native';
import NavBar from '../../NavBar';
import Globals from '../../shared/Globals';
import FeatureTable from '../../shared/feature_view/FeatureTable';
import ListingDetails from '../../shared/feature_view/ListingDetails';
import ActionBar from '../../shared/feature_view/ActionBar';
import BookmarkService from '../../shared/native/BookmarkService';

const ScrollView = ReactNative.ScrollView;
const StyleSheet = ReactNative.StyleSheet;
const Text = ReactNative.Text;
const View = ReactNative.View;

export default class ListingScene extends React.Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    navigator: React.PropTypes.object,
    sceneProps: React.PropTypes.object,
    listing: Globals.propTypes.guideItem.isRequired,
  };

  // noinspection JSUnusedGlobalSymbols
  static title = props => props.listing.name;

  constructor(props) {
    super(props);
    this.state = {
      listing: props.listing,
    };
  }

  _addBookmark = async (item) => {
    const bookmarkKey = await BookmarkService.addBookmarkForItem(item);
    this.setState({ listing: { ...this.state.listing, bookmarkKey } });
  };

  _removeBookmark = (item) => {
    BookmarkService.removeBookmarkForItem(item);
    const newCurrentItem = { ...this.state.listing };
    delete newCurrentItem.bookmarkKey;
    this.setState({ listing: newCurrentItem });
  };

  render() {
    return (
      <View style={styles.container}>
        <NavBar navigator={this.props.navigator} sceneProps={this.props.sceneProps} />
        <ScrollView style={styles.scrollView}>
          {/*<Text style={styles.title}>{this.props.listing.name}</Text>*/}
          <ListingDetails listing={this.props.listing} />
          <FeatureTable listing={this.props.listing} />
        </ScrollView>
        <ActionBar
          feature={this.state.listing}
          addBookmark={this._addBookmark}
          removeBookmark={this._removeBookmark}
        />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  scrollView: {
    paddingTop: 64,
  },
  title: {
    paddingTop: 80,
    fontWeight: '500',
    fontSize: 20,
    padding: 20,
  },
});
