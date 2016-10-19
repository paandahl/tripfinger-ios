import React from 'react';
import ReactNative from 'react-native';
import GuideItemCell from '../shared/GuideItemCell';
import ListingCell from './ListingCell';
import Globals from '../../shared/Globals';
import Utils from '../../shared/Utils';
import { getCascadingListingsForRegion } from '../../shared/ContentService';
import ListingScene from './ListingScene';
import MWMOpeningHours from '../../shared/native/MWMOpeningHours';

const ListView = ReactNative.ListView;
const StyleSheet = ReactNative.StyleSheet;

export default class ListingsList extends React.Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    navigator: Globals.propTypes.navigator.isRequired,
    region: Globals.propTypes.guideItem.isRequired,
    categoryDesc: React.PropTypes.object.isRequired,
  };

  constructor(props) {
    super(props);
    const ds = Utils.simpleDataSource();
    this.data = { };
    this.state = {
      expanded: false,
      dataSource: ds.cloneWithRowsAndSections(this.data),
    };
    this.loadListings();
  }

  loadListings = async () => {
    const subCatValue = this.props.categoryDesc.subCategory;
    const category = subCatValue || this.props.categoryDesc.category;
    const listings = await getCascadingListingsForRegion(this.props.region.uuid, category);
    const likedListings = [];
    const notLikedListings = [];
    for (const listing of listings) {
      if (listing.notes && listing.notes.likedState === 'LIKED') {
        likedListings.push(listing);
      } else {
        notLikedListings.push(listing);
      }
    }
    const sortedListings = likedListings.concat(notLikedListings);
    const data = { listings: sortedListings };
    const sections = ['listings'];
    const dataSource = this.state.dataSource.cloneWithRowsAndSections(data, sections);
    this.setState({ dataSource });
  };

  _navigateToListing = async (listing) => {
    let openListing = listing;
    if (listing.openingHours) {
      const openingHours = await MWMOpeningHours.createOpeningHoursDict(listing.openingHours);
      openListing = { ...listing, openingHours };
    }
    this.props.navigator.push({
      component: ListingScene,
      passProps: {
        listing: openListing,
      },
    });
  };

  renderRow = (data, sectionId, rowId) => {
    if (sectionId === 'guideItem') {
      return <GuideItemCell guideItem={this.props.categoryDesc} initialExpand />;
    } else if (sectionId === 'listings') {
      return (
        <ListingCell
          rowId={rowId} listing={data}
          onPress={() => this._navigateToListing(data)}
        />
      );
    }
    return null;
  };

  render() {
    return (
      <ListView
        dataSource={this.state.dataSource}
        renderRow={this.renderRow}
        renderSeparator={this.renderSeparator}
        style={styles.list}
      />
    );
  }
}

const styles = StyleSheet.create({
  list: {
    flex: 1,
    alignSelf: 'stretch',
    backgroundColor: '#EBEBF1',
  },
  firstRowInSection: {
    marginTop: 20,
  },
});
