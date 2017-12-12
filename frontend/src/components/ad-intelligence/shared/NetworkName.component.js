import React from 'react';
import PropTypes from 'prop-types';

const NetworkName = ({ network }) => (
  <div>
    <img src={`images/${network.id}.png`} width="16px" height="16px" alt={network.name} />
    &nbsp;
    {network.name}
  </div>
);

NetworkName.propTypes = {
  network: PropTypes.shape({
    id: PropTypes.number,
    name: PropTypes.string,
  }).isRequired,
};

export default NetworkName;
