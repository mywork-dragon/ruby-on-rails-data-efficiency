import React from 'react';
import PropTypes from 'prop-types';
import { Panel } from 'react-bootstrap';

const SdkFilterPanel = ({ handleSelect, panelKey }) => (
  <Panel eventKey={panelKey}>
    <Panel.Heading onClick={handleSelect(panelKey)}>
      <Panel.Title>
        SDK Data
        <i className="fa fa-angle-down pull-right" />
      </Panel.Title>
    </Panel.Heading>
    <Panel.Body collapsible>
      Filters go in here
    </Panel.Body>
  </Panel>
);

SdkFilterPanel.propTypes = {
  handleSelect: PropTypes.func,
  panelKey: PropTypes.string.isRequired,
};

SdkFilterPanel.defaultProps = {
  handleSelect: () => {},
};

export default SdkFilterPanel;
