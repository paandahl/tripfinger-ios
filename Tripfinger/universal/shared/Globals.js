import React from 'react';

const PropTypes = React.PropTypes;

const Globals = {


  modeKey: 'mode',
  modes: {
    release: 'release',
    test: 'test',
    draft: 'draft',
    beta: 'beta',
  },

  serverUrl: 'https://server.tripfinger.com',
  imagesUrl: 'https://storage.googleapis.com/tripfinger-images/',
  imageFolder: 'Images',

  propTypes: {
    navigator: PropTypes.shape({
      push: PropTypes.func.isRequired,
    }),
    guideItem: PropTypes.shape({
      slug: PropTypes.string,
      loadStatus: PropTypes.string,
      description: PropTypes.string.isRequired,
      images: PropTypes.array.isRequired,
    }),
    region: PropTypes.shape({
      slug: PropTypes.string.isRequired,
      loadStatus: PropTypes.string.isRequired,
      description: PropTypes.string.isRequired,
      images: PropTypes.array.isRequired,
    }),
  },

  colors: {
    tripfingerBlue: '#2FADF2',
    linkBlue: '#3586FF',
    cancelRed: '#d9534f',
    okBlue: '#337ab7',
    successGreen: '#5cb85c',
    tintGrey: '#333',
    rowBackgroundGrey: '#EFEFF4',
  },

  categories: {
    country: 130,
    subRegion: 130,
    city: 130,
    neighbourhood: 130,

    attractions: 210,
    transportation: 230,
    accommodation: 240,
    foodOrDrink: 250,
    shopping: 260,
    information: 270,
  },

  subCategories: {
    airport: 2300,
    trainStation: 2310,
    busStation: 2320,
    ferryTerminal: 2330,
    carRental: 2340,
    motorbikeRental: 2350,
    bicycleRental: 2360,
    busStop: 2390,
    ferryStop: 2391,
    metroStation: 2391,
    metroEntrance: 2393,
    tramStop: 2394,
  },

  downloadStatus: {
    notDownloaded: 'notDownloaded',
    downloading: 'downloading',
    downloaded: 'downloaded',
  },
};

export default Globals;
