/* global fetch */
export async function getCountries() {
  console.log('Getting countries');
  const url = 'https://server.tripfinger.com/countries?pass=plJR86!!';
  const response = await fetch(url);
  if (response.status === 401) {
    throw new Error(`401 Not Authorized for url: ${url}`);
  } else if (response.status === 404) {
    throw new Error(`404 Not Found for url: ${url}`);
  }
  return await response.json();
}

export function imagesBaseUrl() {
  return 'https://storage.googleapis.com/tripfinger-images/';
}
