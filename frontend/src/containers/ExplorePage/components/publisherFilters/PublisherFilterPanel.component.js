import React from 'react';
import PropTypes from 'prop-types';
import { Panel } from 'react-bootstrap';
import { panelFilterCount } from 'utils/explore/general.utils';

import FilterCountLabel from '../FilterCountLabel.component';
import FortuneRankFilter from './FortuneRankFilter.component';
import HeadquarterFilter from './HeadquarterFilter.component';

const PublisherFilterPanel = ({
  filters,
  filters: {
    fortuneRank,
  },
  panels,
  panelKey,
  togglePanel,
  ...rest
}) => (
  <Panel expanded={panels[panelKey]}>
    <Panel.Heading onClick={togglePanel(panelKey)}>
      <Panel.Title>
        Publisher Details
        <FilterCountLabel count={panelFilterCount(filters, panelKey)} />
        <i className="fa fa-angle-down pull-right" />
      </Panel.Title>
    </Panel.Heading>
    <Panel.Body collapsible>
      <ul className="panel-filters list-unstyled">
        <FortuneRankFilter fortuneRank={fortuneRank} panelKey={panelKey} {...rest} />
        <HeadquarterFilter filter={filters.headquarters} panelKey={panelKey} {...rest} />
      </ul>
    </Panel.Body>
  </Panel>
);

PublisherFilterPanel.propTypes = {
  filters: PropTypes.object.isRequired,
  panels: PropTypes.object.isRequired,
  panelKey: PropTypes.string.isRequired,
  togglePanel: PropTypes.func.isRequired,
};

export default PublisherFilterPanel;
