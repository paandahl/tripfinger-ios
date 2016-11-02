export default class LocalDatabaseServiceMock {

  static _saveRegionCalled = false;

  static saveRegion() {
    LocalDatabaseServiceMock._saveRegionCalled = true;
  }

  static addDownloadMarker() {}

  static isDownloadMarkerCancelled() {}

  static removeDownloadMarker() {}
}
