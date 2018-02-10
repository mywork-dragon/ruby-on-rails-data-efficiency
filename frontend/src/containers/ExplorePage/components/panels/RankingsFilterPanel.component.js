import React from 'react';
import PropTypes from 'prop-types';
import { Panel } from 'react-bootstrap';

const RankingsFilterPanel = ({ handleSelect }) => (
  <Panel eventKey="5">
    <Panel.Heading onClick={handleSelect('5')}>
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
};

RankingsFilterPanel.defaultProps = {
  handleSelect: () => {},
};

export default RankingsFilterPanel;
