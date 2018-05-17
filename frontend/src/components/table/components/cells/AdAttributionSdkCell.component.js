import React from 'react';
import PropTypes from 'prop-types';

import SdkLogo from 'Icons/SdkLogo.component';

const AdAttributionSdkCell = ({ app, platform }) => (
  <div>
    { app.ad_attribution_sdks.map(sdk => <SdkLogo key={sdk.id} platform={app.platform || platform} sdk={sdk} />) }
    { !app.ad_attribution_sdks.length && (app.last_scanned || app.last_scanned_date) ? 'None' : '' }
    { (!app.last_scanned && !app.last_scanned_date) ? 'Not Scanned' : '' }
  </div>
);

AdAttributionSdkCell.propTypes = {
  app: PropTypes.shape({
    id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
    name: PropTypes.string,
  }).isRequired,
  platform: PropTypes.string,
};

AdAttributionSdkCell.defaultProps = {
  platform: 'ios',
};

export default AdAttributionSdkCell;
