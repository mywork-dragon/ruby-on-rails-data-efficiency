import React from 'react';
import PropTypes from 'prop-types';
import { Panel } from 'react-bootstrap';

import FortuneRankFilter from '../publisherFilters/FortuneRankFilter.component';
import HeadquarterFilter from '../publisherFilters/HeadquarterFilter.component';

const PublisherFilterPanel = ({
  filters: {
    fortuneRank,
  },
  handleSelect,
  ...rest
}) => (
  <Panel eventKey="3">
    <Panel.Heading onClick={handleSelect('3')}>
      <Panel.Title>
        Publisher Details
        <i className="fa fa-angle-down pull-right" />
      </Panel.Title>
    </Panel.Heading>
    <Panel.Body collapsible>
      <ul className="panel-filters list-unstyled">
        <FortuneRankFilter fortuneRank={fortuneRank} {...rest} />
        <HeadquarterFilter />
      </ul>
    </Panel.Body>
  </Panel>
);

PublisherFilterPanel.propTypes = {
  filters: PropTypes.object.isRequired,
  handleSelect: PropTypes.func,
};

PublisherFilterPanel.defaultProps = {
  handleSelect: () => {},
};

export default PublisherFilterPanel;
