/* eslint-disable */

beforeAll(() => {
  global.Promise = require.requireActual('promise');
});

jest.mock('realm');
jest.mock('react-native-filesystem');
jest.mock('../../native/SimpleNetworking');
jest.mock('../LocalDatabaseService');
jest.mock('../../OnlineDatabaseService');

import FileSystemMock from 'react-native-filesystem';
import Globals from '../../Globals';
import DownloadService from '../DownloadService';
import SimpleNetworkingMock from '../../native/SimpleNetworking'
import LocalDatabaseServiceMock from '../LocalDatabaseService';
import bruneiPreparsed from './brunei.json';

const bruneiJson = JSON.stringify(bruneiPreparsed);
const countryPath = `${Globals.imageFolder}/Brunei`;

describe('fetchImageListForRegion()', () => {
  it('should return 5 images', () => {
    const imageList = DownloadService.fetchImageListForRegion(JSON.parse(bruneiJson), countryPath);
    expect(imageList.length).toBe(5);
  });

  it('should return destinationPaths starting with /Brunei and set the urls of the images', () => {
    const brunei = JSON.parse(bruneiJson);
    const imageList = DownloadService.fetchImageListForRegion(brunei, countryPath);

    // check paths
    let checkedPath = false;
    for (const image of imageList) {
      if (image.path.includes('ecd22ca8-48d3-448e-8cbb-3cac815eda78')) {
        expect(image.path).toEqual('Images/Brunei/ecd22ca8-48d3-448e-8cbb-3cac815eda78.jpg');
        checkedPath = true;
      }
    }
    expect(checkedPath).toBe(true);

    // check that url is set on guideItems to prepare for offline mode
    let checkedUrl = false;
    for (const listing of brunei.attractions) {
      if (listing.name === 'Ulu Temburong National Park') {
        expect(listing.images[0].url).toEqual('Brunei/ecd22ca8-48d3-448e-8cbb-3cac815eda78.jpg');
        checkedUrl = true;
      }
    }
    expect(checkedUrl).toBe(true);

    // check for subRegion listings as well
    checkedUrl = false;
    for (const subRegion of brunei.subRegions) {
      if (subRegion.name === 'Bandar') {
        for (const listing of subRegion.attractions) {
          if (listing.name === 'Brunei International Airport') {
            const url = listing.images[0].url;
            expect(url).toEqual('Brunei/Bandar/ce6eadc4-1ba0-49de-a212-c19be3b3d3e5.jpg');
            checkedUrl = true;
          }
        }
      }
    }
    expect(checkedUrl).toBe(true);
  });
});

describe('processDownload()', () => {
  it('should download 5 images', async () => {
    SimpleNetworkingMock._downloadsCount = 0;
    FileSystemMock._file = bruneiJson;
    await DownloadService.processDownload('brunei.json', countryPath, {}, () => {});
    expect(SimpleNetworkingMock._downloadsCount).toBe(5);
  });

  it('should download images from the correct GCS bucket', async () => {
    SimpleNetworkingMock._lastDownload = null;
    FileSystemMock._file = bruneiJson;
    await DownloadService.processDownload('brunei.json', countryPath, {}, () => {});
    expect(SimpleNetworkingMock._lastDownload.startsWith(Globals.imagesUrl)).toBe(true);
  });

  it('should call LocalDatabaseService upon completion', async () => {
    LocalDatabaseServiceMock._saveRegionCalled = false;
    FileSystemMock._file = bruneiJson;
    await DownloadService.processDownload('brunei.json', countryPath, {}, () => {});
    expect(LocalDatabaseServiceMock._saveRegionCalled).toBe(true);
  });

  it('should update progress upon completion', async () => {
    FileSystemMock._file = bruneiJson;
    let progress = 0.0;
    await DownloadService.processDownload('brunei.json', countryPath, {}, (prog) => {
      progress = prog;
    });
    expect(progress).toBe(1.0);
  });
});

describe('downloadCountry()', () => {
  it('should return true on success', async () => {
    const brunei = {
      name: 'Brunei',
    };
    const result = await DownloadService.downloadCountry(brunei, 'test', undefined, () => {});
    expect(result).toBe(true);
  });

  it('should download json and 5 images', async () => {
    SimpleNetworkingMock._downloadsCount = 0;
    FileSystemMock._file = bruneiJson;
    await DownloadService.downloadCountry(JSON.parse(bruneiJson), 'test', undefined, () => {});
    expect(SimpleNetworkingMock._downloadsCount).toBe(6);
  });

});
