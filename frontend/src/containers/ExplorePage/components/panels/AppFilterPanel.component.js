import React from 'react';
import PropTypes from 'prop-types';
import { Panel } from 'react-bootstrap';
import { panelFilterCount } from 'utils/explore/general.utils';

import AvailableCountriesFilter from '../appFilters/AvailableCountriesFilter.component';
import CategoriesFilter from '../appFilters/CategoriesFilter.component';
import FilterCountLabel from '../FilterCountLabel.component';
import InAppPurchaseFilter from '../appFilters/InAppPurchaseFilter.component';
import MobilePriorityFilter from '../appFilters/MobilePriorityFilter.component';
import PriceFilter from '../appFilters/PriceFilter.component';
import UserbaseFilter from '../appFilters/UserbaseFilter.component';

const AppFilterPanel = ({
  filters,
  filters: {
    availableCountries,
    inAppPurchases,
    price,
    mobilePriority,
    userBase,
    iosCategories,
    androidCategories,
  },
  panels,
  panelKey,
  togglePanel,
  ...rest
}) => (
  <Panel expanded={panels[panelKey]}>
    <Panel.Heading onClick={togglePanel(panelKey)}>
      <Panel.Title>
        App Details
        <FilterCountLabel count={panelFilterCount(filters, panelKey)} />
        <i className="fa fa-angle-down pull-right" />
      </Panel.Title>
    </Panel.Heading>
    <Panel.Body collapsible>
      <ul className="panel-filters list-unstyled">
        <MobilePriorityFilter mobilePriority={mobilePriority} panelKey={panelKey} {...rest} />
        <PriceFilter filter={price} panelKey={panelKey} {...rest} />
        <InAppPurchaseFilter filter={inAppPurchases} panelKey={panelKey} {...rest} />
        <AvailableCountriesFilter filter={availableCountries} panelKey={panelKey} {...rest} />
        <CategoriesFilter androidFilter={androidCategories} iosFilter={iosCategories} panelKey={panelKey} {...rest} />
        <UserbaseFilter panelKey={panelKey} userBase={userBase} {...rest} />
      </ul>
    </Panel.Body>
  </Panel>
);

AppFilterPanel.propTypes = {
  filters: PropTypes.object.isRequired,
  panels: PropTypes.object.isRequired,
  panelKey: PropTypes.string.isRequired,
  togglePanel: PropTypes.func.isRequired,
};

export default AppFilterPanel;
