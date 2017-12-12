import React from 'react';
import PropTypes from 'prop-types';

import { Tooltip, OverlayTrigger } from 'react-bootstrap';

const SdkLogo = ({ sdk, platform }) => {
  const tooltip = (
    <Tooltip id="tooltip">{sdk.name}</Tooltip>
  );

  const link = `#/sdk/${platform}/${sdk.id}`;

  return (
    <OverlayTrigger placement="top" overlay={tooltip}>
      <a href={link} target="_blank">
        <img src={sdk.favicon} width="16" height="16" alt={sdk.name} />
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
