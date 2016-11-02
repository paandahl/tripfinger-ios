export class GuideItemImage {
  // noinspection JSUnusedGlobalSymbols
  static schema = {
    name: GuideItemImage.name,
    properties: {
      imageDescription: 'string',
      license: 'string',
      artist: 'string',
      originalUrl: 'string',
    },
  }
}

export class GuideItemNotes {
  // noinspection JSUnusedGlobalSymbols
  static schema = {
    name: GuideItemNotes.name,
    properties: {
      listingId: 'string',
      likedState: 'int',
    },
  }
}

export class GuideItem {
  // noinspection JSUnusedGlobalSymbols
  static schema = {
    name: GuideItem.name,
    properties: {
      entityType: { type: 'string' },
      uuid: 'string',
      name: 'string',
      slug: { type: 'string', optional: true },
      category: 'int',
      subCategory: 'int',
      status: 'int',
      parentUuid: { type: 'string', optional: true },
      description: { type: 'string', optional: true },
      textLicense: { type: 'string', optional: true },
      images: { type: 'list', objectType: GuideItemImage.name },
      guideSections: { type: 'list', objectType: GuideItem.name },
      subRegions: { type: 'list', objectType: GuideItem.name },
      categoryDescriptions: { type: 'list', objectType: GuideItem.name },

      // GuideListing
      longitude: { type: 'float', optional: true },
      latitude: { type: 'float', optional: true },
      continent: { type: 'string', optional: true },
      worldArea: { type: 'string', optional: true },
      country: { type: 'string', optional: true },
      region: { type: 'string', optional: true },
      subRegion: { type: 'string', optional: true },
      city: { type: 'string', optional: true },
      notes: { type: GuideItemNotes.name, optional: true },

      // Listing
      website: { type: 'string', optional: true },
      email: { type: 'string', optional: true },
      address: { type: 'string', optional: true },
      phone: { type: 'string', optional: true },
      price: { type: 'string', optional: true },
      openingHours: { type: 'string', optional: true },
      directions: { type: 'string', optional: true },

      // Region
      mwmRegionId: { type: 'string', optional: true },
      draftSizeInBytes: { type: 'double', optional: true },
      stagedSizeInBytes: { type: 'double', optional: true },
      publishedSizeInBytes: { type: 'double', optional: true },
      listings: { type: 'list', objectType: GuideItem.name },

    },
  }
}

export const LikedState = {
  NOT_YET_LIKED_OR_SWIPED: 0,
  SWIPED_LEFT: 1,
  LIKED: 2,
};

export const schemas = [GuideItemNotes, GuideItem, GuideItemImage];
