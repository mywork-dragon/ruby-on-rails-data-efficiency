import React from 'react';
import PropTypes from 'prop-types';
import { Tooltip, OverlayTrigger } from 'react-bootstrap';

import SmallIcon from './SmallIcon';

const SdkLogo = ({ sdk, platform }) => {
  const tooltip = (
    <Tooltip id="tooltip">{sdk.name}</Tooltip>
  );

  const link = `#/sdk/${platform}/${sdk.id}`;

  if (!sdk.favicon) sdk.favicon = `/welcome/sdk/icon/${platform}/${sdk.id}`;

  return (
    <OverlayTrigger overlay={tooltip} placement="top">
      <a href={link} target="_blank">
        <SmallIcon alt={sdk.name} src={sdk.favicon} />
      </a>
    </OverlayTrigger>
  );
};

SdkLogo.propTypes = {
  sdk: PropTypes.shape({
    name: PropTypes.string,
    id: PropTypes.number,
    favicon: PropTypes.string,
  }).isRequired,
  platform: PropTypes.string.isRequired,
};

export default SdkLogo;
