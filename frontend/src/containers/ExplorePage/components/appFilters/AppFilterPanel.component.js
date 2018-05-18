import React from 'react';
import PropTypes from 'prop-types';
import { Panel } from 'react-bootstrap';
import { panelFilterCount, formatCategoriesForSelect } from 'utils/explore/general.utils';

import AvailableCountriesFilter from './AvailableCountriesFilter.component';
import CategoriesFilter from '../CategoriesFilter.component';
import DownloadsFilter from './DownloadsFilter.component';
import FilterCountLabel from '../FilterCountLabel.component';
import InAppPurchaseFilter from './InAppPurchaseFilter.component';
import MobilePriorityFilter from './MobilePriorityFilter.component';
import PermissionsFilter from './PermissionsFilter.component';
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
    categories,
    ratingsCount,
    rating,
    releaseDate,
    downloads,
    appPermissions,
  },
  iosCategories,
  androidCategories,
  panels,
  panelKey,
  togglePanel,
  canAccessAppPermissions,
  ...rest
}) => {
  iosCategories = iosCategories.filter(x => x.name !== 'Overall');
  androidCategories = androidCategories.filter(x => !/^FAMILY/.test(x.id) && x.id !== 'OVERALL');
  const categoryOptions = formatCategoriesForSelect(iosCategories, androidCategories);

  return (
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
          <CategoriesFilter
            onCategoryUpdate={vals => rest.updateFilter('categories', vals, { panelKey })()}
            options={categoryOptions}
            panelKey={panelKey}
            value={categories ? categories.value : []}
            {...rest}
          />
          {canAccessAppPermissions && <PermissionsFilter filter={appPermissions} panelKey={panelKey} {...rest} />}
          <RatingFilter filter={rating} panelKey={panelKey} {...rest} />
          <RatingsCountFilter filter={ratingsCount} panelKey={panelKey} {...rest} />
          <DownloadsFilter filter={downloads} panelKey={panelKey} {...rest} />
          <ReleaseDateFilter filter={releaseDate} panelKey={panelKey} {...rest} />
        </ul>
      </Panel.Body>
    </Panel>
  );
};

AppFilterPanel.propTypes = {
  filters: PropTypes.object.isRequired,
  panels: PropTypes.object.isRequired,
  panelKey: PropTypes.string.isRequired,
  togglePanel: PropTypes.func.isRequired,
  iosCategories: PropTypes.arrayOf(PropTypes.object).isRequired,
  androidCategories: PropTypes.arrayOf(PropTypes.object).isRequired,
  canAccessAppPermissions: PropTypes.bool,
};

AppFilterPanel.defaultProps = {
  canAccessAppPermissions: false,
};

export default AppFilterPanel;
