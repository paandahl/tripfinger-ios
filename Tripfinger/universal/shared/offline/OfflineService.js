import Realm from 'realm';
import { schemas, GuideListingNotes } from './Schema';

const realm = new Realm({
  schema: schemas,
});

export default class OfflineService {


  static saveLikeInLocalDb(likedState, listingId) {
    const listingNotes = OfflineService.getAttachedListingNotes(listingId);
    if (listingNotes) {
      realm.write(() => {
        listingNotes.likedState = likedState;
      });
    } else {
      const offlineListing = OfflineService.getAttachedListingWithId(listingId);
      const guideListingNotes = { likedState, listingId };
      realm.write(() => {
        realm.create(GuideListingNotes.name, guideListingNotes);
        if (offlineListing) {
          offlineListing.listing.notes = guideListingNotes;
        }
      });
    }
  }

  static deleteListingNotes(listingId) {
    const listingNotes = OfflineService.getAttachedListingNotes(listingId);
    realm.write(() => {
      realm.delete(listingNotes);
    });
  }

  static getListingNotes(listingId) {
    const attachedListingNotes = OfflineService.getAttachedListingNotes(listingId);
    return { ...attachedListingNotes };
  }

//
//   class func getListingNotes(listingId: String) -> GuideListingNotes? {
//   let listingNotes = getAttachedListingNotes(listingId)
//   return detachListingNotes(listingNotes)
// }

  static getAttachedListingNotes(listingId) {
    const allNotes = realm.objects(GuideListingNotes.name);
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
