class MockRequest {
  // noinspection Eslint
  async completion() {
  }
}

export default class SimpleNetworking {

  static _downloadsCount = 0;
  static _lastDownload = null;
  static _file;

  static storage = {
    BACKED_UP: 'BACKED_UP',
    AUXILIARY_IMPORTANT: 'AUXILIARY_IMPORTANT',
    AUXILIARY: 'AUXILIARY',
    TEMPORARY: 'TEMPORARY',
  };

  static async readFile() {
    return SimpleNetworking._file;
  }

  static async fileExists() {
    return false;
  }

  static async downloadFile({ url }) {
    SimpleNetworking._downloadsCount += 1;
    SimpleNetworking._lastDownload = url;
    return new MockRequest();
  }

  // noinspection Eslint
  static async deleteFile() {}
}
