import React from 'react';
import PropTypes from 'prop-types';
import { Tooltip, OverlayTrigger } from 'react-bootstrap';

import SmallIcon from './SmallIcon';

const AdNetworkLogo = ({ id, name }) => {
  const tooltip = (
    <Tooltip id="tooltip">{name}</Tooltip>
  );

  return (
    <OverlayTrigger overlay={tooltip} placement="top">
      <SmallIcon alt={name} src={`images/${id}.png`} />
    </OverlayTrigger>
  );
};

AdNetworkLogo.propTypes = {
  id: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
};

export default AdNetworkLogo;
