// <editor-fold desc="Imports">
import React from 'react';

const PropTypes = React.PropTypes;
// </editor-fold>

export default {
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
};

