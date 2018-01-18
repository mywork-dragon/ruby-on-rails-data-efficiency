import React from 'react';
import PropTypes from 'prop-types';

import { longDate } from 'utils/format.utils';

import AppNameCell from './cells/AppNameCell.component';
import AdNetworkCell from './cells/AdNetworkCell.component';
import AdAttributionSdkCell from './cells/AdAttributionSdkCell.component';
import CheckboxCell from './cells/CheckboxCell.component';
import CreativeFormatCell from './cells/CreativeFormatCell.component';

const AppTableCell = ({
  allSelected,
  app,
  isAdIntel,
  networks,
  platform,
  toggleItem,
  type,
}) => {
  if (type === 'App') {
    return (
      <AppNameCell app={app} isAdIntel={isAdIntel} platform={platform} />
    );
  } else if (type === 'checkbox') {
    return (
      <CheckboxCell
        isSelected={allSelected}
        toggleItem={toggleItem}
      />
    );
  } else if (type === 'Networks') {
    return (
      <AdNetworkCell networks={app.ad_networks} overallNetworks={networks} />
    );
  } else if (type === 'Ad Attribution SDKs') {
    return (
      <AdAttributionSdkCell app={app} platform={platform} />
    );
  } else if (type === 'Formats') {
    return (
      <CreativeFormatCell formats={app.creative_formats} />
    );
  } else if (type === 'Total Creatives Seen') {
    return (
      <td>{app.number_of_creatives}</td>
    );
  } else if (type === 'First Seen Ads') {
    return (
      <td>{longDate(app.first_seen_ads_date)}</td>
    );
  } else if (type === 'Last Seen Ads') {
    return (
      <td>{longDate(app.last_seen_ads_date)}</td>
    );
  }
};

AppTableCell.propTypes = {
  allSelected: PropTypes.bool,
  app: PropTypes.shape({
    id: PropTypes.string,
    name: PropTypes.name,
  }).isRequired,
  isAdIntel: PropTypes.bool,
  networks: PropTypes.arrayOf(PropTypes.object),
  platform: PropTypes.string,
  toggleItem: PropTypes.func,
  type: PropTypes.string.isRequired,
};

AppTableCell.defaultProps = {
  allSelected: false,
  isAdIntel: false,
  networks: [],
  platform: 'ios',
  toggleItem: null,
};

export default AppTableCell;
