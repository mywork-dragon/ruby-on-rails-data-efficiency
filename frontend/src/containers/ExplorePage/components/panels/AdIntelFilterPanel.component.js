import React from 'react';
import PropTypes from 'prop-types';
import { Panel } from 'react-bootstrap';

const AdIntelFilterPanel = ({ handleSelect }) => (
  <Panel eventKey="4">
    <Panel.Heading onClick={handleSelect('4')}>
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
};

AdIntelFilterPanel.defaultProps = {
  handleSelect: () => {},
};

export default AdIntelFilterPanel;
