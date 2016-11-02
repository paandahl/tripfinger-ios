import ReactNative from 'react-native';
import FileSystem from 'react-native-filesystem';

// noinspection JSUnresolvedVariable
const NativeModules = ReactNative.NativeModules;
const NativeEventEmitter = ReactNative.NativeEventEmitter;
const RNSimpleNetworking = NativeModules.RNSimpleNetworking;
const RNSimpleNetworkingEmitter = NativeModules.RNSimpleNetworkingEmitter;

const eventEmitter = new NativeEventEmitter(RNSimpleNetworkingEmitter);

class DownloadRequest {
  constructor() {
    this._finishedPromise = new Promise((resolve) => {
      this._finishedPromiseResolver = resolve;
    });
  }

  _initialize = (taskIdentifier, absolutePath, progressHandler) => {
    this._taskId = taskIdentifier;
    this._progressHandler = progressHandler;
    this._absolutePath = absolutePath;
    if (this._taskId === 0) {
      this._finishedPromiseResolver(this._absolutePath);
    }
  };

  cancel = () => {
    if (this._taskId) {
      // noinspection JSUnresolvedFunction
      RNSimpleNetworking.cancelRequest(this._taskId);
    }
  };

  _updateProgress = (taskId, progress) => {
    if (taskId === this._taskId) {
      this._progressHandler(progress);
    }
  };

  _setComplete = (taskId) => {
    if (taskId === this._taskId) {
      this._finishedPromiseResolver(this._absolutePath);
      return true;
    }
    return false;
  };

  onComplete = () => this._finishedPromise;
}

export default class SimpleNetworking {

  static async downloadFile({
    url,
    path,
    storage = FileSystem.storage.important,
    overwrite = true,
    method = 'GET',
    body = null,
    progressHandler = null,
  }) {
    const request = new DownloadRequest();
    let progressSubscription;
    if (progressHandler) {
      progressSubscription = eventEmitter.addListener(
        RNSimpleNetworkingEmitter.DOWNLOAD_PROGRESS,
        (event) => {
          request._updateProgress(event.taskId, event.progress);
        },
      );
    }
    const statusSubscription = eventEmitter.addListener(
      RNSimpleNetworkingEmitter.DOWNLOAD_STATUS_CHANGED,
      (event) => {
        if (event.error) {
          throw new Error(event.error);
        }
        const completed = request._setComplete(event.taskId);
        if (completed) {
          eventEmitter.removeSubscription(statusSubscription);
          if (progressSubscription) {
            eventEmitter.removeSubscription(progressSubscription);
          }
        }
      },
    );
    const { taskId, absolutePath } =
      await RNSimpleNetworking.downloadFile(url, path, storage, method, body, overwrite);
    request._initialize(taskId, absolutePath, progressHandler);
    return request;
  }
}
