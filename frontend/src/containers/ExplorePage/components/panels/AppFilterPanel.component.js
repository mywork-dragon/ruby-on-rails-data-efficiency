import React from 'react';
import PropTypes from 'prop-types';
import { Panel } from 'react-bootstrap';

import AvailableCountriesFilter from '../appFilters/AvailableCountriesFilter.component';
import CategoriesFilter from '../appFilters/CategoriesFilter.component';
import InAppPurchaseFilter from '../appFilters/InAppPurchaseFilter.component';
import MobilePriorityFilter from '../appFilters/MobilePriorityFilter.component';
import PriceFilter from '../appFilters/PriceFilter.component';
import UserbaseFilter from '../appFilters/UserbaseFilter.component';

const AppFilterPanel = ({
  filters: {
    appCategory,
    mobilePriority,
    userBase,
  },
  handleSelect,
  ...rest
}) => (
  <Panel eventKey="2">
    <Panel.Heading onClick={handleSelect('2')}>
      <Panel.Title>
        App Details
        <i className="fa fa-angle-down pull-right" />
      </Panel.Title>
    </Panel.Heading>
    <Panel.Body collapsible>
      <ul className="panel-filters list-unstyled">
        <MobilePriorityFilter mobilePriority={mobilePriority} {...rest} />
        <PriceFilter />
        <InAppPurchaseFilter />
        <AvailableCountriesFilter />
        <CategoriesFilter filter={appCategory} {...rest} />
        <UserbaseFilter userBase={userBase} {...rest} />
      </ul>
    </Panel.Body>
  </Panel>
);

AppFilterPanel.propTypes = {
  filters: PropTypes.object.isRequired,
  handleSelect: PropTypes.func,
};

AppFilterPanel.defaultProps = {
  handleSelect: () => {},
};

export default AppFilterPanel;
