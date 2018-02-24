import React from 'react';
import PropTypes from 'prop-types';
import { Panel } from 'react-bootstrap';
import { panelFilterCount } from 'utils/explore/general.utils';

import FilterCountLabel from '../FilterCountLabel.component';
import FortuneRankFilter from '../publisherFilters/FortuneRankFilter.component';
import HeadquarterFilter from '../publisherFilters/HeadquarterFilter.component';

const PublisherFilterPanel = ({
  filters,
  filters: {
    fortuneRank,
  },
  handleSelect,
  panelKey,
  ...rest
}) => (
  <Panel eventKey={panelKey}>
    <Panel.Heading onClick={handleSelect(panelKey)}>
      <Panel.Title>
        Publisher Details
        <FilterCountLabel count={panelFilterCount(filters, panelKey)} />
        <i className="fa fa-angle-down pull-right" />
      </Panel.Title>
    </Panel.Heading>
    <Panel.Body collapsible>
      <ul className="panel-filters list-unstyled">
        <FortuneRankFilter fortuneRank={fortuneRank} panelKey={panelKey} {...rest} />
        <HeadquarterFilter />
      </ul>
    </Panel.Body>
  </Panel>
);

PublisherFilterPanel.propTypes = {
  filters: PropTypes.object.isRequired,
  handleSelect: PropTypes.func,
  panelKey: PropTypes.string.isRequired,
};

PublisherFilterPanel.defaultProps = {
  handleSelect: () => {},
};

export default PublisherFilterPanel;
