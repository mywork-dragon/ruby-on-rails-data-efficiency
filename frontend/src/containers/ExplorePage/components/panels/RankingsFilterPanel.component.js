import React from 'react';
import PropTypes from 'prop-types';
import { Panel } from 'react-bootstrap';

const RankingsFilterPanel = ({ handleSelect, panelKey }) => (
  <Panel eventKey={panelKey}>
    <Panel.Heading onClick={handleSelect(panelKey)}>
      <Panel.Title>
        Rankings
        <i className="fa fa-angle-down pull-right" />
      </Panel.Title>
    </Panel.Heading>
    <Panel.Body collapsible>
      Filters go in here
    </Panel.Body>
  </Panel>
);

RankingsFilterPanel.propTypes = {
  handleSelect: PropTypes.func,
  panelKey: PropTypes.string.isRequired,
};

RankingsFilterPanel.defaultProps = {
  handleSelect: () => {},
};

export default RankingsFilterPanel;
