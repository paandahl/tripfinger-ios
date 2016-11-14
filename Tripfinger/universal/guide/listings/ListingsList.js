import React from 'react';
import ReactNative from 'react-native';
import GuideItemCell from '../shared/GuideItemCell';
import ListingCell from './ListingCell';
import Globals from '../../shared/Globals';
import Utils from '../../shared/Utils';
import { getCascadingListingsForRegion } from '../../shared/OnlineDatabaseService';
import ListingScene from './ListingScene';
import MWMOpeningHours from '../../shared/native/MWMOpeningHours';
import ListViewContainer from '../../shared/components/ListViewContainer';
import StandardCell from '../../shared/components/StandardCell';
import CategoryScene from './CategoryScene';

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
    this.data = {};
    this.sections = [];
    const notAttractions = this.props.categoryDesc.category !== Globals.categories.attractions;
    const desc = this.props.categoryDesc.description;
    if (notAttractions && desc && desc !== '<p></p>') {
      this.data.guideItem = [this.props.categoryDesc];
      this.sections.push('guideItem');
    }
    const ds = Utils.simpleDataSource();
    this.state = {
      expanded: false,
      dataSource: ds.cloneWithRowsAndSections(this.data),
    };
    this.loadListings();
  }

  loadListings = async () => {
    const catDesc = this.props.categoryDesc;
    const subCatValue = catDesc.subCategory;
    const category = subCatValue || catDesc.category;
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
    if (catDesc.category === Globals.categories.transportation
        && catDesc.categoryDescriptions.length > 0) {
      this.data.subCats =
        catDesc.categoryDescriptions.sort((a, b) => a.subCategory - b.subCategory);
      this.sections.push('subCats');
    } else {
      this.data.listings = likedListings.concat(notLikedListings);
      this.sections.push('listings');
    }
    const dataSource = this.state.dataSource.cloneWithRowsAndSections(this.data, this.sections);
    this.setState({ dataSource });
  };

  _navigateToSubCategory = (subCatDesc) => {
    this.props.navigator.push({
      component: CategoryScene,
      passProps: {
        region: this.props.region,
        categoryDesc: subCatDesc,
      },
    });
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

  renderRow = (data, sectionId, isFirstRow, isLastRow) => {
    const props = { isFirstRow, isLastRow };
    if (sectionId === 'guideItem') {
      return <GuideItemCell guideItem={this.props.categoryDesc} />;
    } else if (sectionId === 'listings') {
      const onPress = () => this._navigateToListing(data);
      return <ListingCell listing={data} onPress={onPress} {...props} />;
    } else if (sectionId === 'subCats') {
      const text = Utils.categoryName(data.subCategory);
      const onPress = () => this._navigateToSubCategory(data);
      return <StandardCell onPress={onPress} text={text} {...props} />;
    }
    return null;
  };

  render() {
    return (
      <ListViewContainer
        automaticallyAdjustContentInsets={false}
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
