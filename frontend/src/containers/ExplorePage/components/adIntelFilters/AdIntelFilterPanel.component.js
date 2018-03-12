import React from 'react';
import PropTypes from 'prop-types';
import { Panel } from 'react-bootstrap';

import AdNetworkFilter from './AdNetworkFilter.component';
import CreativeFormatFilter from './CreativeFormatFilter.component';

const AdIntelFilterPanel = ({
  filters: {
    adNetworks,
    creativeFormats,
  },
  togglePanel,
  panelKey,
  panels,
  ...rest
}) => (
  <Panel expanded={panels[panelKey]}>
    <Panel.Heading onClick={togglePanel(panelKey)}>
      <Panel.Title>
        Ad Intelligence
        <i className="fa fa-angle-down pull-right" />
      </Panel.Title>
    </Panel.Heading>
    <Panel.Body collapsible>
      <ul className="panel-filters list-unstyled">
        <AdNetworkFilter filter={adNetworks} panelKey={panelKey} {...rest} />
        <CreativeFormatFilter filter={creativeFormats} panelKey={panelKey} {...rest} />
      </ul>
    </Panel.Body>
  </Panel>
);

AdIntelFilterPanel.propTypes = {
  filters: PropTypes.object.isRequired,
  togglePanel: PropTypes.func.isRequired,
  panelKey: PropTypes.string.isRequired,
  panels: PropTypes.object.isRequired,
};

export default AdIntelFilterPanel;
