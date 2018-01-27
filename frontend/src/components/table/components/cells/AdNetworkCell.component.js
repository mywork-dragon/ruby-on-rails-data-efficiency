import React from 'react';
import PropTypes from 'prop-types';

import { sortNetworks } from 'utils/ad-intelligence.utils';

import AdNetworkLogo from 'Icons/AdNetworkLogo.component';

const AdNetworkCell = ({
  fetchAdNetworks,
  fetching,
  networks,
  networksLoaded,
  visibleNetworks,
  showName,
}) => {
  if (!networksLoaded && !fetching) {
    fetchAdNetworks();
    return null;
  }

  return (
    <div className="creative-cell">
      {
        showName ? (
          <span>
            <AdNetworkLogo {...networks[0]} />
            {networks[0].name}
          </span>
        ) : sortNetworks(visibleNetworks, networks).map(network => (<AdNetworkLogo key={network.id} {...network} />))
      }
    </div>
  );
};

AdNetworkCell.propTypes = {
  fetchAdNetworks: PropTypes.func,
  fetching: PropTypes.bool,
  networks: PropTypes.arrayOf(PropTypes.object).isRequired,
  networksLoaded: PropTypes.bool,
  visibleNetworks: PropTypes.arrayOf(PropTypes.object).isRequired,
  showName: PropTypes.bool,
};

AdNetworkCell.defaultProps = {
  fetchAdNetworks: null,
  fetching: false,
  networksLoaded: false,
  showName: false,
};

export default AdNetworkCell;
