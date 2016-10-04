/* global fetch */

const BASE_URL = 'https://server.tripfinger.com';
const PASS = 'plJR86!!';

function addPass(url) {
  if (url.includes("?")) {
    return `${url}&pass=${PASS}`;
  } else {
    return `${url}?pass=${PASS}`;
  }
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
  const url = `${BASE_URL}/countries`;
  const countries = await fetchJson(addPass(url));
  for (const country of countries) {
    country.loadStatus = 'CHILDREN_NOT_LOADED';
  }
  return countries;
}

export async function getRegionWithSlug(slug) {
  // if let region = DatabaseService.getRegionWithSlug(slug) {
  //   handler(region)
  //   return
  // }
  const url = `${BASE_URL}/regions/${slug}?slug=true`;
  return await fetchJson(addPass(url));
}

export async function getGuideTextWithId(guideTextId) {
  // if let guideText = DatabaseService.getGuideTextWithId(guideTextId) {
  //   handler(guideText)
  //   return
  // }
  const url = `${BASE_URL}/guideTexts/${guideTextId}`;
  return await fetchJson(addPass(url));
}

export function imagesBaseUrl() {
  return 'https://storage.googleapis.com/tripfinger-images/';
}
