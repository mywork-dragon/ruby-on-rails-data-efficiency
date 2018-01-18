import React from 'react';
import PropTypes from 'prop-types';

import AdNetworkLogo from 'Icons/AdNetworkLogo.component';

const NetworkName = ({ network }) => (
  <span>
    <AdNetworkLogo id={network.id} name={network.name} />
    {network.name}
  </span>
);

NetworkName.propTypes = {
  network: PropTypes.shape({
    id: PropTypes.string,
    name: PropTypes.string,
  }).isRequired,
};

export default NetworkName;
