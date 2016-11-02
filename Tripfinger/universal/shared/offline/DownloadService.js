import FileSystem from 'react-native-filesystem';
import Utils from '../Utils';
import Globals from '../Globals';
import SimpleNetworkingg from '../native/SimpleNetworking';
import LocalDatabaseService from './LocalDatabaseService';
import { getDownloadUrl } from '../OnlineDatabaseService';

export default class DownloadService {

  static async downloadCountry(country, deviceUuid, receipt, progressHandler) {
    const mwmRegionId = country.mwmRegionId || country.name;
    LocalDatabaseService.addDownloadMarker(mwmRegionId);
    Utils.disableIdleTimer();
    const taskHandle = Utils.beginBackgroundTask(() => {
      Utils.endBackgroundTask(taskHandle);
    });
    // dispatch_async(dispatch_get_main_queue()) {
    //   NSNotificationCenter.defaultCenter().postNotificationName(TFDownloadStartedNotification,
    // object: mwmRegionId)
    // }

    const countryPath = `${country.name}`;
    const jsonPath = `${countryPath}/${country.name}.json`;
    const hasEnoughFreeSpace = await Utils.checkIfDeviceHasEnoughFreeSpaceForRegion(country);
    if (!hasEnoughFreeSpace) {
      DownloadService.cleanupDownload(country, taskHandle, jsonPath);
      return false;
    }

    const url = getDownloadUrl(country, receipt, deviceUuid);
    const jsonExists = await FileSystem.fileExists(jsonPath, FileSystem.storage.important);
    if (jsonExists) {
      await DownloadService.processDownload(jsonPath, countryPath, taskHandle, progressHandler);
    } else {
      const jsonRequest = await SimpleNetworkingg.downloadFile({
        url,
        path: jsonPath,
        storage: FileSystem.storage.AUXILIARY_IMPORTANT,
        method: (receipt) ? 'POST' : 'GET',
        body: receipt,
      });
      await jsonRequest.onComplete();
      await DownloadService.processDownload(jsonPath, countryPath, taskHandle, progressHandler);
    }
    return true;
  }

  static async processDownload(jsonPath, countryPath, taskHandle, progressHandler) {
    const jsonData = await FileSystem.readFile(jsonPath);
    const region = JSON.parse(jsonData);
    const imageList = DownloadService.fetchImageListForRegion(region, countryPath);
    let counter = 0.0;
    await DownloadService.splitImageListAndDownload(imageList, (requests) => { // progressHandler
      counter += 1;
      if (LocalDatabaseService.isDownloadMarkerCancelled(region.mwmRegionId || region.name)) {
        requests.forEach(req => req.cancel());
        DownloadService.deleteCountry(region.name);
        DownloadService.cleanupDownload(region, taskHandle, jsonPath);
        return;
      }
      const progress = counter / imageList.count;
      if (progressHandler) {
        progressHandler(progress);
      }
    });
    if (LocalDatabaseService.isDownloadMarkerCancelled(region.mwmRegionId || region.name)) {
      return;
    }
    console.log('Finished image downloads');
    await LocalDatabaseService.saveRegion(region);
    console.log('Persisted region to database');
    if (progressHandler) {
      progressHandler(1.0);
    }
    DownloadService.cleanupDownload(region, taskHandle, jsonPath);
  }

  static deleteCountry() {}

  static cleanupDownload(region, taskHandle, jsonPath) {
    LocalDatabaseService.removeDownloadMarker(region.mwmRegionId || region.name);
    Utils.enableIdleTimer();
    Utils.endBackgroundTask(taskHandle);
    FileSystem.deleteFile(jsonPath);
  }

  static fetchImageListForRegion(region, path) {
    let imageList = DownloadService.fetchImageListForGuideItem(region, path);
    for (const listing of region.attractions) {
      imageList = imageList.concat(DownloadService.fetchImageListForGuideItem(listing, path));
    }
    for (const subRegion of region.subRegions) {
      const subPath = `${path}/${subRegion.name}`;
      imageList = imageList.concat(DownloadService.fetchImageListForRegion(subRegion, subPath));
    }
    return imageList;
  }

  static getLocalPartOfFileUrl(fileUrl) {
    const flag = 'Images/';
    const startIndex = fileUrl.lastIndexOf(flag) + flag.length;
    return fileUrl.substring(startIndex);
  }

  static fetchImageListForGuideItem(guideItem, path) {
    let imageList = [];
    for (const image of guideItem.images) {
      const destinationPath = `${path}/${image.url}`;
      imageList.push({ url: image.url, path: destinationPath });
      image.url = DownloadService.getLocalPartOfFileUrl(destinationPath);
    }
    if (guideItem.guideSections) {
      for (const guideSection of guideItem.guideSections) {
        imageList =
          imageList.concat(DownloadService.fetchImageListForGuideItem(guideSection, path));
      }
    }
    if (guideItem.categoryDescriptions) {
      for (const catDesc of guideItem.categoryDescriptions) {
        imageList = imageList.concat(DownloadService.fetchImageListForGuideItem(catDesc, path));
      }
    }
    return imageList;
  }

  static async splitImageListAndDownload(imageList, progressHandler) {
    const requestList = [];
    for (const { url, path } of imageList) {
      const fileExists = await FileSystem.fileExists(path);
      if (fileExists) {
        progressHandler(requestList);
      } else {
        const imageUrl = Globals.imagesUrl + url;
        const request = await SimpleNetworkingg.downloadFile({ url: imageUrl, path });
        request.onComplete().then(() => {
          progressHandler(requestList);
        });
        requestList.push(request.onComplete());
      }
    }
    await Promise.all(requestList);
  }
}
