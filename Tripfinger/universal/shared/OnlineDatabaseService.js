/* global fetch */

import ReactNative from 'react-native';
import LocalDatabaseService from './offline/LocalDatabaseService';
import Globals from './Globals';

const Settings = ReactNative.Settings;

const BASE_URL = 'https://server.tripfinger.com';
const PASS = 'plJR86!!';

function addParam(url, paramName, paramValue) {
  if (url.includes('?')) {
    return `${url}&${paramName}=${paramValue}`;
  } else {
    return `${url}?${paramName}=${paramValue}`;
  }
}

function addPass(url) {
  return addParam(url, 'pass', PASS);
}

function getFetchType() {
  const appMode = Settings.get(Globals.modeKey);
  switch (appMode) {
    case Globals.modes.release:
      return 'ONLY_PUBLISHED';
    case Globals.modes.beta:
      return 'STAGED_OR_PUBLISHED';
    case Globals.modes.draft:
    case Globals.modes.test:
      return 'NEWEST';
    default:
      throw new Error(`Unrecognized appMode: ${appMode}`);
  }
}

function addFetchType(url) {
  return addParam(url, 'fetchType', getFetchType());
}

async function fetchJson(url) {
  const response = await fetch(url);
  if (response.status === 401) {
    throw new Error(`401 Not Authorized for url: ${url}`);
  } else if (response.status === 404) {
    throw new Error(`404 Not Found for url: ${url}`);
  }
  return await response.json();
}

export async function getCountries() {
  let url = `${BASE_URL}/countries`;
  url = addFetchType(url);
  const countries = await fetchJson(addPass(url));
  for (const country of countries) {
    country.loadStatus = 'CHILDREN_NOT_LOADED';
  }
  return countries;
}

export async function getCountryWithName() {}

export async function getRegionWithSlug(slug) {
  const offlineRegion = LocalDatabaseService.getGuideItemWithSlug(slug);
  if (offlineRegion) {
    return offlineRegion;
  }

  let url = `${BASE_URL}/regions/${slug}?slug=true`;
  url = addPass(addFetchType(url));
  return await fetchJson(url);
}

export async function getGuideTextWithId(guideTextId) {
  const offlineGuideText = LocalDatabaseService.getGuideItemWithId(guideTextId);
  if (offlineGuideText) {
    return offlineGuideText;
  }

  const url = `${BASE_URL}/guideTexts/${guideTextId}`;
  return await fetchJson(addPass(addFetchType(url)));
}

export async function getCascadingListingsForRegion(regionId, category) {
  const offlineRegion = LocalDatabaseService.getGuideItemWithId(regionId);
  if (offlineRegion) {
    return LocalDatabaseService.getCascadingListingsForRegion(offlineRegion);
  }

  let url = `${BASE_URL}/regions/${regionId}/attractions`;
  url = addParam(url, 'cascade', 'true');

  if (category) {
    url = addParam(url, 'categoryId', category);
  }
  // for listing in listings {
  //   if let notes = DatabaseService.getListingNotes(listing.item().uuid) {
  //     listing.listing.notes = notes
  //   }
  // }
  return await fetchJson(addPass(addFetchType(url)));
}

export function getDownloadUrl(country, receipt, deviceUuid) {
  let url;
  if (receipt) {
    url = `${Globals.serverUrl}/download_purchased_country/${country.name}`;
  } else {
    url = `${Globals.serverUrl}/download_first_country/${country.name}/${deviceUuid}`;
  }
  return addPass(addFetchType(url));
}
