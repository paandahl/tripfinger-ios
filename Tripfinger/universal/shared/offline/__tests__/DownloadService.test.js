/* eslint-disable */

beforeAll(() => {
  global.Promise = require.requireActual('promise');
});

jest.mock('realm');
jest.mock('react-native-filesystem');
jest.mock('../../native/SimpleNetworking');
jest.mock('../LocalDatabaseService');

import Globals from '../../Globals';
import DownloadService from '../DownloadService';
import SimpleNetworkingMock from '../../native/SimpleNetworking'
import LocalDatabaseServiceMock from '../LocalDatabaseService';
import brunei from './brunei.json';

const countryPath = `${DownloadService.imagePath}/Brunei`;

describe('fetchImageListForRegion()', () => {
  it('should return 5 images', () => {
    const imageList = DownloadService.fetchImageListForRegion(brunei, countryPath);
    expect(imageList.length).toBe(5);
  });

  it('should return destinationPaths starting with /Brunei', () => {
    const imageList = DownloadService.fetchImageListForRegion(brunei, countryPath);
    const entry = imageList[0];
    expect(entry.path.startsWith('/Brunei')).toBe(true);
  });
});

describe('processDownload()', () => {
  it('should download 5 images', async () => {
    SimpleNetworkingMock._downloadsCount = 0;
    SimpleNetworkingMock._file = JSON.stringify(brunei);
    await DownloadService.processDownload('brunei.json', countryPath, {}, () => {});
    expect(SimpleNetworkingMock._downloadsCount).toBe(5);
  });

  it('should download images from the correct GCS bucket', async () => {
    SimpleNetworkingMock._lastDownload = null;
    SimpleNetworkingMock._file = JSON.stringify(brunei);
    await DownloadService.processDownload('brunei.json', countryPath, {}, () => {});
    expect(SimpleNetworkingMock._lastDownload.startsWith(Globals.imagesUrl)).toBe(true);
  });

  it('should call LocalDatabaseService upon completion', async () => {
    LocalDatabaseServiceMock._saveRegionCalled = false;
    await DownloadService.processDownload('brunei.json', countryPath, {}, () => {});
    expect(LocalDatabaseServiceMock._saveRegionCalled).toBe(true);
  });

  it('should update progress upon completion', async () => {
    SimpleNetworkingMock._file = JSON.stringify(brunei);
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
    SimpleNetworkingMock._file = JSON.stringify(brunei);
    await DownloadService.downloadCountry(brunei, 'test', undefined, () => {});
    expect(SimpleNetworkingMock._downloadsCount).toBe(6);
  });

});
