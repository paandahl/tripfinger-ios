import Realm from 'realm';
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

  static addDownloadMarker(mwmRegionId) {}

  static isDownloadMarkerCancelled() {}

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
    const allItems = realm.objects(GuideItem.name);
    const items = allItems.filtered(`uuid = "${id}"`);
    if (items.length > 0) {
      return detachGuideItem(items[0]);
    }
    return null;
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
    console.log(listings.length);
    for (let i = 0; i < listings.length; i += 1) {
      const listing = listings[i];
      console.log(listing);
      if (listing.latitude !== 0 && listing.longitude !== 0) {
        list.push(detachGuideItem(listing));
      }
    }
    return list;
  }

  static saveRegion(region) {
    return new Promise((resolve) => {
      realm.write(() => {
        realm.create(GuideItem.name, region);
      });
      resolve();
    });
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
}
