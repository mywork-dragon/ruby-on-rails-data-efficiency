import React from 'react';
import PropTypes from 'prop-types';

import { sortNetworks } from 'utils/ad-intelligence.utils';

import AdNetworkLogo from 'Icons/AdNetworkLogo.component';

const AdNetworkCell = ({ networks, overallNetworks, showName }) => (
  <td className="creative-cell">
    {
      showName ? (
        <span>
          <AdNetworkLogo {...networks[0]} />
          {networks[0].name}
        </span>
      ) : sortNetworks(overallNetworks, networks).map(network => (<AdNetworkLogo key={network.id} {...network} />))
    }
  </td>
);

AdNetworkCell.propTypes = {
  networks: PropTypes.arrayOf(PropTypes.object).isRequired,
  overallNetworks: PropTypes.arrayOf(PropTypes.object).isRequired,
  showName: PropTypes.bool,
};

AdNetworkCell.defaultProps = {
  showName: false,
};

export default AdNetworkCell;
