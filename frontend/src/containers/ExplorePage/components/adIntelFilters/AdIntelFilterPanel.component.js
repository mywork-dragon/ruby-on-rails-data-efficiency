import React from 'react';
import PropTypes from 'prop-types';
import { Panel } from 'react-bootstrap';
import { panelFilterCount } from 'utils/explore/general.utils';

import AdNetworkFilter from './AdNetworkFilter.component';
import CreativeFormatFilter from './CreativeFormatFilter.component';
import FilterCountLabel from '../FilterCountLabel.component';
import NetworkCountFilter from './NetworkCountFilter.component';

const AdIntelFilterPanel = ({
  filters,
  filters: {
    adNetworks: networksFilter,
    creativeFormats,
    adNetworkCount,
  },
  shouldFetchAdNetworks,
  adNetworks,
  facebookOnly,
  getAdNetworks,
  togglePanel,
  panelKey,
  panels,
  ...rest
}) => {
  if (shouldFetchAdNetworks) {
    getAdNetworks();
  }

  return (
    <Panel expanded={panels[panelKey]}>
      <Panel.Heading onClick={togglePanel(panelKey)}>
        <Panel.Title>
          Ad Intelligence
          <FilterCountLabel count={panelFilterCount(filters, panelKey)} />
          <i className="fa fa-angle-down pull-right" />
        </Panel.Title>
      </Panel.Heading>
      <Panel.Body collapsible>
        <ul className="panel-filters list-unstyled">
          <AdNetworkFilter accountNetworks={adNetworks} facebookOnly={facebookOnly} filter={networksFilter} panelKey={panelKey} {...rest} />
          {!facebookOnly && (
            <NetworkCountFilter adNetworks={adNetworks} filter={adNetworkCount} panelKey={panelKey} {...rest} />
          )}
          {!facebookOnly && (
            <CreativeFormatFilter filter={creativeFormats} panelKey={panelKey} {...rest} />
          )}
        </ul>
      </Panel.Body>
    </Panel>
  );
};

AdIntelFilterPanel.propTypes = {
  filters: PropTypes.object.isRequired,
  togglePanel: PropTypes.func.isRequired,
  panelKey: PropTypes.string.isRequired,
  panels: PropTypes.object.isRequired,
  shouldFetchAdNetworks: PropTypes.bool.isRequired,
  adNetworks: PropTypes.arrayOf(PropTypes.object).isRequired,
  facebookOnly: PropTypes.bool.isRequired,
  getAdNetworks: PropTypes.func.isRequired,
};

export default AdIntelFilterPanel;
