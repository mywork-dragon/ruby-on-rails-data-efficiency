import React from 'react';
import PropTypes from 'prop-types';

import SdkLogo from 'Icons/SdkLogo.component';

const AdAttributionSdkCell = ({ app, platform }) => (
  <div>
    { app.ad_attribution_sdks.map(sdk => <SdkLogo key={sdk.id} platform={app.platform || platform} sdk={sdk} />) }
    { !app.ad_attribution_sdks.length && app.last_scanned ? 'None' : '' }
    { !app.last_scanned ? 'Not Scanned' : '' }
  </div>
);

AdAttributionSdkCell.propTypes = {
  app: PropTypes.shape({
    id: PropTypes.string,
    name: PropTypes.name,
  }).isRequired,
  platform: PropTypes.string,
};

AdAttributionSdkCell.defaultProps = {
  platform: 'ios',
};

export default AdAttributionSdkCell;
