import React from 'react';
import PropTypes from 'prop-types';
import { Panel } from 'react-bootstrap';

const AdIntelFilterPanel = ({ handleSelect, panelKey }) => (
  <Panel eventKey={panelKey}>
    <Panel.Heading onClick={handleSelect(panelKey)}>
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
  handleSelect: PropTypes.func,
  panelKey: PropTypes.string.isRequired,
};

AdIntelFilterPanel.defaultProps = {
  handleSelect: () => {},
};

export default AdIntelFilterPanel;
