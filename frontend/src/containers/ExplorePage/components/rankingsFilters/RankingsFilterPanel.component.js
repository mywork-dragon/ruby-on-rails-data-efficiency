import React from 'react';
import PropTypes from 'prop-types';
import { Panel } from 'react-bootstrap';
import { panelFilterCount } from 'utils/explore/general.utils';

import ChartsFilter from './ChartsFilter.component';
import FilterCountLabel from '../FilterCountLabel.component';
import RankingsFilter from './RankingsFilter.component';

const RankingsFilterPanel = ({
  filters,
  togglePanel,
  panelKey,
  panels,
  ...rest
}) => (
  <Panel expanded={panels[panelKey]}>
    <Panel.Heading onClick={togglePanel(panelKey)}>
      <Panel.Title>
        Rankings
        <FilterCountLabel count={panelFilterCount(filters, panelKey)} />
        <i className="fa fa-angle-down pull-right" />
      </Panel.Title>
    </Panel.Heading>
    <Panel.Body collapsible>
      <RankingsFilter filter={filters.rankings} panelKey={panelKey} {...rest} />
      <ChartsFilter filter={filters.rankings} panelKey={panelKey} {...rest} />
    </Panel.Body>
  </Panel>
);

RankingsFilterPanel.propTypes = {
  filters: PropTypes.object.isRequired,
  togglePanel: PropTypes.func.isRequired,
  panelKey: PropTypes.string.isRequired,
  panels: PropTypes.object.isRequired,
};

export default RankingsFilterPanel;
