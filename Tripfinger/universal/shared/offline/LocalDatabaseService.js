import Realm from 'realm';
import FileSystem from 'react-native-filesystem';
import { schemas, GuideItem, GuideItemNotes } from './Schema';
import Globals from '../Globals';

const realm = new Realm({
  schema: schemas,
});

function detachGuideItem(guideItem, withChildren = true) {
  const detachedItem = { ...guideItem };
  detachedItem.description = detachedItem.description || '';
  detachedItem.images = detachImages(detachedItem);
  const subRegions = [];
  const guideSections = [];
  const categoryDescriptions = [];
  if (withChildren) {
    for (let i = 0; i < detachedItem.subRegions.length; i += 1) {
      const subRegion = detachedItem.subRegions[i];
      subRegions.push(detachGuideItem(subRegion, false));
    }
    for (let i = 0; i < detachedItem.guideSections.length; i += 1) {
      const section = detachedItem.guideSections[i];
      guideSections.push(detachGuideItem(section, true));
    }
    for (let i = 0; i < detachedItem.categoryDescriptions.length; i += 1) {
      const catDesc = detachedItem.categoryDescriptions[i];
      categoryDescriptions.push(detachGuideItem(catDesc, true));
    }
  } else {
    detachedItem.loadStatus = 'NOT_LOADED';
  }
  detachedItem.subRegions = subRegions;
  detachedItem.guideSections = guideSections;
  detachedItem.categoryDescriptions = categoryDescriptions;
  return detachedItem;
}

function detachImages(guideItem) {
  const images = [];
  for (let i = 0; i < guideItem.images.length; i += 1) {
    const image = guideItem.images[i];
    images.push({ ...image });
  }
  return images;
}

export default class LocalDatabaseService {

  static addDownloadMarker(countryId) {}

  static isDownloadMarkerCancelled() {}

  static hasDownloadMarker(countryId) {}

  static removeDownloadMarker() {}

  static getGuideItemWithSlug(slug) {
    const allItems = realm.objects(GuideItem.name);
    const items = allItems.filtered(`slug = "${slug}"`);
    if (items.length > 0) {
      return detachGuideItem(items[0]);
    }
    return null;
  }

  static getGuideItemWithId(id) {
    const attachedGuideItem = LocalDatabaseService._getAttachedGuideItemWithId(id);
    if (attachedGuideItem == null) {
      return null;
    } else {
      return detachGuideItem(attachedGuideItem);
    }
  }

  static _getAttachedGuideItemWithId(id) {
    const allItems = realm.objects(GuideItem.name);
    const items = allItems.filtered(`uuid = "${id}"`);
    if (items.length > 0) {
      return items[0];
    }
    return null;
  }

  static getDownloadStatusForId(id) {
    if (LocalDatabaseService.getGuideItemWithId(id)) {
      return Globals.downloadStatus.downloaded;
    } else if (LocalDatabaseService.hasDownloadMarker(id)) {
      return Globals.downloadStatus.downloading;
    } else {
      return Globals.downloadStatus.notDownloaded;
    }
  }

  static getCascadingListingsForRegion(region) {
    let query;
    switch (region.category) {
      case Globals.categories.country:
        query = `entityType = "listing" and country = "${region.name}"`;
        break;
      case Globals.categories.subRegion:
        query = `entityType = "listing" and country = "${region.country}" and subRegion = "${region.name}"`;
        break;
      case Globals.categories.city:
        query = `entityType = "listing" and country = "${region.country}" and city = "${region.name}"`;
        break;
      case Globals.categories.neighbourhood:
        query = `entityType = "listing" and parentUuid = "${region.uuid}"`;
        break;
      default:
        throw new Error(`Cascade not supported for type: ${region.category}`);
    }
    const listings = realm.objects(GuideItem.name).filtered(query);
    const list = [];
    for (let i = 0; i < listings.length; i += 1) {
      const listing = listings[i];
      if (listing.latitude !== 0 && listing.longitude !== 0) {
        list.push(detachGuideItem(listing));
      }
    }
    return list;
  }

  static fixFetchedJsonForDb(region) {
    region.listings = region.attractions;
    if (region.subRegions) {
      for (const subRegion of region.subRegions) {
        LocalDatabaseService.fixFetchedJsonForDb(subRegion);
      }
    }
  }

  static saveRegion(region) {
    LocalDatabaseService.fixFetchedJsonForDb(region);
    realm.write(() => {
      realm.create(GuideItem.name, region);
    });
  }

  static deleteRegion(regionId) {
    const attachedRegion = LocalDatabaseService._getAttachedGuideItemWithId(regionId);
    realm.write(() => {
      LocalDatabaseService._deleteGuideItem(attachedRegion);
    });
  }

  static _deleteGuideItem(guideItem) {
    while (guideItem.subRegions.length > 0) {
      const subRegion = guideItem.subRegions[0];
      LocalDatabaseService._deleteGuideItem(subRegion);
    }
    while (guideItem.listings.length > 0) {
      const listing = guideItem.listings[0];
      LocalDatabaseService._deleteGuideItem(listing);
    }
    while (guideItem.guideSections.length > 0) {
      const section = guideItem.guideSections[0];
      LocalDatabaseService._deleteGuideItem(section);
    }
    while (guideItem.categoryDescriptions.length > 0) {
      const catDesc = guideItem.categoryDescriptions[0];
      LocalDatabaseService._deleteGuideItem(catDesc);
    }
    while (guideItem.images.length > 0) {
      const image = guideItem.images[0];
      realm.delete(image);
    }
    realm.delete(guideItem);
  }

  static saveLikeInLocalDb(likedState, listingId) {
    const listingNotes = LocalDatabaseService.getAttachedListingNotes(listingId);
    if (listingNotes) {
      realm.write(() => {
        listingNotes.likedState = likedState;
      });
    } else {
      const offlineListing = LocalDatabaseService.getAttachedListingWithId(listingId);
      const guideListingNotes = { likedState, listingId };
      realm.write(() => {
        realm.create(GuideItemNotes.name, guideListingNotes);
        if (offlineListing) {
          offlineListing.listing.notes = guideListingNotes;
        }
      });
    }
  }

  static deleteListingNotes(listingId) {
    const listingNotes = LocalDatabaseService.getAttachedListingNotes(listingId);
    realm.write(() => {
      realm.delete(listingNotes);
    });
  }

  static getListingNotes(listingId) {
    const attachedListingNotes = LocalDatabaseService.getAttachedListingNotes(listingId);
    return { ...attachedListingNotes };
  }

//
//   class func getListingNotes(listingId: String) -> GuideListingNotes? {
//   let listingNotes = getAttachedListingNotes(listingId)
//   return detachListingNotes(listingNotes)
// }

  static getAttachedListingNotes(listingId) {
    const allNotes = realm.objects(GuideItemNotes.name);
    const notes = allNotes.filtered(`listingId = "${listingId}"`);
    if (notes.length > 0) {
      return notes[0];
    }
    return null;
  }

  static getAttachedListingWithId(listingId) {
    return null;
  }

  static getCustomListingFeatures() {
    const allListings = realm.objects(GuideItem.name).filtered('entityType = "listing"');
    const iterator = allListings.values();
    const features = [];
    let iter = iterator.next();
    while (!iter.done) {
      const listing = iter.value;
      features.push({
        latitude: listing.latitude,
        longitude: listing.longitude,
        name: listing.name,
        category: listing.category,
        type: LocalDatabaseService.getOsmListingType(listing.subCategory),
        id: listing.uuid,
      });
      iter = iterator.next();
    }
    return features;
  }

  static getCustomRegionFeatures() {
    const allListings = realm.objects(GuideItem.name).filtered('entityType = "region"');
    const iterator = allListings.values();
    const features = [];
    let iter = iterator.next();
    while (!iter.done) {
      const listing = iter.value;
      features.push({
        latitude: listing.latitude,
        longitude: listing.longitude,
        name: listing.name,
        category: listing.category,
        type: LocalDatabaseService.getOsmRegionType(listing.category),
        id: listing.uuid,
      });
      iter = iterator.next();
    }
    return features;
  }

  static getOsmRegionType(categoryId) {
    switch (categoryId) {
      case 110: // continent
        return 4188;
      case 120: // world area
      case 140: // country region
      case 150: // subregion
        return 5020; // county
      case 130: // country
        return 4252;
      case 160: // city
        return 17825820;
      default:
        console.log(`osmType not defined for category: ${categoryId}`);
        return 17825820; // amenity-bus_station
    }
  }

  static getOsmListingType(subCategoryId) {
    switch (subCategoryId) {
      case 2100: // sights nnd landmarks
        return 4259; // tourism-attraction
      case 2110: // tours
        return 4259; // tourism-attraction
      case 2120: // museums
        return 4771; // tourism-museum
      case 2130: // park
        return 4498; // leisure-park
      case 2140: // hood
        return 4259; // tourism-attraction
      case 2145: // nature
        return 4498; // leisure-park
      case 2150: // daytrips
        return 4259; // tourism-attraction
      case 2155: // sports
        return 4259; // tourism-attraction
      case 2160: // amusement park
        return 4259; // tourism-attraction
      case 2165: // fun and games
        return 4259; // tourism-attraction
      case 2170: // class or workshop
        return 4259; // tourism-attraction
      case 2175: // spa or wellness
        return 4259; // tourism-attraction
      case 2180: // theater and concernts:
        return 7042; // amenity-theatre
      case 2185: // festivals
        return 4259; // tourism-attraction

      case 2300: // airport
        return 4097; // aeroway-aerodrome
      case 2310: // train station
        return 5279; // railway-station
      case 2320: // bus station
        return 4610; // amenity-bus_station
      case 2392: // metro station
        return 271519; // railway-station-subway
      case 2394: // tram stop
        return 4610; // amenity-bus_station
      case 2330: // ferry terminal
        return 4610; // amenity-bus_station
      case 2340: // car rental
        return 4610; // amenity-bus_station
      case 2350: // motorbike rental
        return 4610; // amenity-bus_station
      case 2360: // bicycle rental
        return 4610; // amenity-bus_station

      case 2410: // guesthouses
      case 2420: // hotels
      case 2430: // apartments
      case 2400: // hostels
        return 4579; // tourism-hotel

      case 2500:
        return 4674; // amenity-cafe
      case 2510:
        return 6658; // amenity-restaurant
      case 2530:
        return 4226; // amenity-bar
      case 2540:
        return 6274; // amenity-nightclub
      case 2520:
        return 5570; // amenity-fast_food

      case 2600:
        return 6210; // amenity-marketplace
      case 2610:
        return 5985; // shop-mall
      case 2620:
        return 97; // shop

      case 2700:
        return 266787; // tourism-information-office

      default:
        console.log(`osmType not defined for category: ${subCategoryId}`);
        return 4610; // amenity-bus_station
    }
  }
}
