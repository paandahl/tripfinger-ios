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

export class GuideItem {
  // noinspection JSUnusedGlobalSymbols
  static schema = {
    name: GuideItem.name,
    properties: {
      uuid: 'string',
      name: 'string',
      slug: { type: 'string', optional: true },
      category: 'int',
      subCategory: 'int',
      status: 'int',
      parent: 'string',
      content: { type: 'string', optional: true },
      textLicense: { type: 'string', optional: true },
      images: { type: 'list', objectType: GuideItemImage.name },
      guideSections: { type: 'list', objectType: 'GuideText' },
      subRegions: { type: 'list', objectType: 'Region' },
      categoryDescriptions: { type: 'list', objectType: 'GuideText' },
    },
  }
}

export class GuideListingNotes {
  // noinspection JSUnusedGlobalSymbols
  static schema = {
    name: GuideListingNotes.name,
    properties: {
      listingId: 'string',
      likedState: 'int',
    },
  }
}

export class GuideListing {
  // noinspection JSUnusedGlobalSymbols
  static schema = {
    name: GuideListing.name,
    properties: {
      item: GuideItem.name,
      longitude: 'float',
      latitude: 'float',
      continent: { type: 'string', optional: true },
      worldArea: { type: 'string', optional: true },
      country: { type: 'string', optional: true },
      region: { type: 'string', optional: true },
      subRegion: { type: 'string', optional: true },
      city: { type: 'string', optional: true },
      notes: { type: GuideListingNotes.name, optional: true },
    },
  }
}

export class Listing {
  // noinspection JSUnusedGlobalSymbols
  static schema = {
    name: Listing.name,
    properties: {
      listing: GuideListing.name,
      website: { type: 'string', optional: true },
      email: { type: 'string', optional: true },
      address: { type: 'string', optional: true },
      phone: { type: 'string', optional: true },
      price: { type: 'string', optional: true },
      openingHours: { type: 'string', optional: true },
      directions: { type: 'string', optional: true },
    },
  }
}

export class Region {
  // noinspection JSUnusedGlobalSymbols
  static schema = {
    name: Region.name,
    properties: {
      listing: GuideListing.name,
      mwmRegionId: 'string',
      draftSizeInBytes: { type: 'double', optional: true },
      stagedSizeInBytes: { type: 'double', optional: true },
      publishedSizeInBytes: { type: 'double', optional: true },
      listings: { type: 'list', objectType: Listing.name },
    },
  }
}

export const LikedState = {
  NOT_YET_LIKED_OR_SWIPED: 0,
  SWIPED_LEFT: 1,
  LIKED: 2,
};

export class GuideText {
  // noinspection JSUnusedGlobalSymbols
  static schema = {
    name: GuideText.name,
    properties: {
      item: GuideItem.name,
    },
  }
}

export const schemas = [Region, Listing, GuideListing, GuideListingNotes, GuideText,
  GuideItem, GuideItemImage];
