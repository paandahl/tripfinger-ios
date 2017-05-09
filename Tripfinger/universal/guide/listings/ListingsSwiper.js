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

const Animated = ReactNative.Animated;
const StyleSheet = ReactNative.StyleSheet;
const View = ReactNative.View;

export default class ListingsSwiper extends React.Component {

  // noinspection JSUnusedGlobalSymbols
  static propTypes = {
    navigator: Globals.propTypes.navigator.isRequired,
    region: Globals.propTypes.guideItem.isRequired,
    categoryDesc: React.PropTypes.object.isRequired,
  };

  constructor(props) {
    super(props);
    this.state = {
      listingStack: null,
      frontCardTop: new Animated.Value(15),
      frontCardLeft: new Animated.Value(15),
    };

    this.loadListings();
  }

  componentWillMount() {
    this.panResponder = new Utils.PanResponderWrapper({
      getStartValue: () => this.featureTopValue,
      onPanResponderMove: (evt, gestureState, startY) => {
        // const newY = startY + gestureState.dy;
        // this.state.featureTop.setValue(newY);
        // const newX = startY + gestureState.dy;
        // this.state.featureTop.setValue(newY);
        console.log(gestureState);
      },
      onPanResponderRelease: (evt, gestureState) => {
        // if (gestureState.dy)
        // if (this.state.viewState === ViewState.HEADER) {
        //   if (gestureState.vy < -0.01 || gestureState.dy < -10) { // swipe up or dragged 10px up
        //     this._expand();
        //   } else if (gestureState.vy > 0.01 || gestureState.dy > 10) { // swipe or dragged down
        //     this._popDown();
        //   } else {
        //     this._popToHeader();
        //   }
        // } else if (this.state.viewState === ViewState.EXPANDED) {
        //   const expandPoint = -(Math.min(this.height, 600) - 100);
        //   if (this.featureTopValue > -100) {
        //     this._popDown();
        //   } else if (this.featureTopValue > expandPoint) {
        //     this._popToHeader();
        //   } else if (gestureState.vy >= 1) {
        //     this._expand();
        //   }
        // }
      },
    });
  }

  loadListings = async () => {
    const catDesc = this.props.categoryDesc;
    const subCatValue = catDesc.subCategory;
    const category = subCatValue || catDesc.category;
    const listings = await getCascadingListingsForRegion(this.props.region.uuid, category);


    const listingStack = [];
    for (const listing of listings) {
      if (!listing.notes) {
        listingStack.push(listing);
      }
    }
    this.setState({ listingStack });
  };

  _navigateToListing = async (listing) => {
    let openListing = listing;
    if (listing.openingHours) {
      const openingHours = await MWMOpeningHours.createOpeningHoursDict(listing.openingHours);
      openListing = { ...listing, openingHours };
    }
    this.props.navigator.push({
      scene: ListingScene,
      props: {
        listing: openListing,
      },
    });
  };

  _renderCard = (listing) => {
    const president = {
      name: 'Trump',
      age: 70,
    };

    const { name, age } = president;
    console.log(`President ${name} is ${age} years old.`);
    return (
      <Animated.View
        style={[{ top: this.state.frontCardTop, left: this.state.frontCardLeft }, styles.card]}
        {...this.panResponder.panHandlers()}
      />
    );
  };

  render() {
    return (
      <View style={styles.container}>
        {this._renderCard()}
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  card: {
    width: 300,
    height: 400,
    backgroundColor: '#f00',
  },
});
