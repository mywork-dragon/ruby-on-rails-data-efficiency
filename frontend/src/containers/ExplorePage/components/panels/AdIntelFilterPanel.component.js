import React from 'react';
import PropTypes from 'prop-types';
import { Panel } from 'react-bootstrap';

const AdIntelFilterPanel = ({
  togglePanel,
  panelKey,
  panels,
}) => (
  <Panel expanded={panels[panelKey]}>
    <Panel.Heading onClick={togglePanel(panelKey)}>
      <Panel.Title>
        Ad Intelligence
        <i className="fa fa-angle-down pull-right" />
      </Panel.Title>
    </Panel.Heading>
    <Panel.Body collapsible>
      Filters go in here
    </Panel.Body>
  </Panel>
);

AdIntelFilterPanel.propTypes = {
  togglePanel: PropTypes.func.isRequired,
  panelKey: PropTypes.string.isRequired,
  panels: PropTypes.object.isRequired,
};

export default AdIntelFilterPanel;
