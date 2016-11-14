import React from 'react';
import ReactNative from 'react-native';

// noinspection JSUnresolvedVariable
const NativeEventEmitter = ReactNative.NativeEventEmitter;
const MWMSearchNative = ReactNative.NativeModules.MWMSearch;
const MWMSearchEmitter = ReactNative.NativeModules.MWMSearchEmitter;

const eventEmitter = new NativeEventEmitter(MWMSearchEmitter);

let searchSubscription;

export default class MWMSearch {

  static async lastQueries() {
    return await MWMSearchNative.lastQueries();
  }

  static cancel() {
    if (searchSubscription) {
      eventEmitter.removeSubscription(searchSubscription);
      searchSubscription = null;
    }
  }

  static search(query, callback) {
    if (searchSubscription) {
      eventEmitter.removeSubscription(searchSubscription);
      searchSubscription = null;
    }
    searchSubscription = eventEmitter.addListener(
      MWMSearchEmitter.SEARCH_RESULTS,
      (event) => {
        console.log(`got search results: ${event.results.length}`);
        callback(event.results);
      },
    );

    // noinspection JSUnresolvedFunction
    MWMSearchNative.search(query);
  }
}
