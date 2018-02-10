import React from 'react';
import PropTypes from 'prop-types';
import { Panel } from 'react-bootstrap';

const SdkFilterPanel = ({ handleSelect }) => (
  <Panel eventKey="1">
    <Panel.Heading onClick={handleSelect('1')}>
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
};

SdkFilterPanel.defaultProps = {
  handleSelect: () => {},
};

export default SdkFilterPanel;
