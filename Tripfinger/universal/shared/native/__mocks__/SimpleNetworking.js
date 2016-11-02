class MockRequest {
  // noinspection Eslint
  async onComplete() {
  }
}

export default class SimpleNetworking {

  static _downloadsCount = 0;
  static _lastDownload = null;

  static storage = {
    BACKED_UP: 'BACKED_UP',
    AUXILIARY_IMPORTANT: 'AUXILIARY_IMPORTANT',
    AUXILIARY: 'AUXILIARY',
    TEMPORARY: 'TEMPORARY',
  };


  static async downloadFile({ url }) {
    SimpleNetworking._downloadsCount += 1;
    SimpleNetworking._lastDownload = url;
    return new MockRequest();
  }
}
