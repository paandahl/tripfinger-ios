/* global navigator */
import ReactNative from 'react-native';
import NativeHeading from 'react-native-heading';

const DeviceEventEmitter = ReactNative.DeviceEventEmitter;

const watcherOptions = {
  enableHighAccuracy: true,
  timeout: 20000,
  maximumAge: 1000,
};

class LocationManager {

  started = false;

  constructor() {
    this.currentLocation = null;
    this.currentHeading = 0;
    this.observers = {};
  }

  _gotPosition = (position) => {
    this.currentLocation = position;
    for (const key of Object.keys(this.observers)) {
      this.observers[key](position, this.currentHeading);
    }
  };

  _gotHeading = (heading) => {
    this.currentHeading = heading;
    for (const key of Object.keys(this.observers)) {
      this.observers[key](this.currentLocation, heading);
    }
  };

  _positionError = (error) => {
    console.log(`Error retrieving position: ${error}`);
  };

  async start() {
    this.watchId = navigator.geolocation.watchPosition(
      this._gotPosition, this._positionError, watcherOptions);
    this.started = true;
    try {
      const didStart = await NativeHeading.start(3);
      console.log(`Did start compass: ${didStart}`);
    } catch (error) {
      console.log(`HeadingError: ${error}`);
    }
    DeviceEventEmitter.addListener('headingUpdated', (data) => {
      this._gotHeading(data.heading);
    });
  }

  pushLocation() {
    navigator.geolocation.getCurrentPosition(
      this._gotPosition, this._positionError, watcherOptions);
  }

  addObserver(name, callback) {
    this.observers[name] = callback;
    if (this.currentLocation !== null) {
      callback(this.currentLocation);
    }
    if (!this.started) {
      this.start();
    }
  }

  removeObserver(name) {
    delete this.observers[name];
    if (Object.keys(this.observers).length === 0) {
      this.stop();
    }
  }

  stop() {
    navigator.geolocation.clearWatch(this.watchId);
    NativeHeading.stop();
    DeviceEventEmitter.removeAllListeners('headingUpdated');
  }
}

const locationManager = new LocationManager();

export default locationManager;
