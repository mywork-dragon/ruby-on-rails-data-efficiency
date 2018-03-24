import React from 'react';
import PropTypes from 'prop-types';
import { Panel } from 'react-bootstrap';
import { panelFilterCount } from 'utils/explore/general.utils';

import AvailableCountriesFilter from './AvailableCountriesFilter.component';
import CategoriesFilter from './CategoriesFilter.component';
import FilterCountLabel from '../FilterCountLabel.component';
import InAppPurchaseFilter from './InAppPurchaseFilter.component';
import MobilePriorityFilter from './MobilePriorityFilter.component';
import PriceFilter from './PriceFilter.component';
import RatingFilter from './RatingFilter.component';
import RatingsCountFilter from './RatingsCountFilter.component';
import ReleaseDateFilter from './ReleaseDateFilter.component';
import UserbaseFilter from './UserbaseFilter.component';

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
    ratingsCount,
    rating,
    releaseDate,
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
        <UserbaseFilter panelKey={panelKey} userBase={userBase} {...rest} />
        <PriceFilter filter={price} panelKey={panelKey} {...rest} />
        <InAppPurchaseFilter filter={inAppPurchases} panelKey={panelKey} {...rest} />
        <AvailableCountriesFilter filter={availableCountries} panelKey={panelKey} {...rest} />
        <CategoriesFilter androidFilter={androidCategories} iosFilter={iosCategories} panelKey={panelKey} {...rest} />
        <RatingFilter filter={rating} panelKey={panelKey} {...rest} />
        <RatingsCountFilter filter={ratingsCount} panelKey={panelKey} {...rest} />
        <ReleaseDateFilter filter={releaseDate} panelKey={panelKey} {...rest} />
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
