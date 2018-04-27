import React from 'react';
import PropTypes from 'prop-types';
import CategoriesDropdown from './CategoriesDropdown.component';

const CategoriesFilter = ({
  title,
  androidCategories,
  androidFilter,
  iosCategories,
  iosFilter,
  platform,
  onCategoryUpdate,
  ...rest
}) => (
  <li className="li-filter">
    <label className="filter-label">
      {title}
    </label>
    <div className="input-group" id="categories-input">
      <CategoriesDropdown
        categories={iosCategories}
        filterCategories={iosFilter}
        onCategoryUpdate={onCategoryUpdate('ios')}
        platform="ios"
        selectedPlatform={platform}
        {...rest}
      />
      <CategoriesDropdown
        categories={androidCategories}
        filterCategories={androidFilter}
        onCategoryUpdate={onCategoryUpdate('android')}
        platform="android"
        selectedPlatform={platform}
        {...rest}
      />
    </div>
  </li>
);

CategoriesFilter.propTypes = {
  title: PropTypes.string,
  androidCategories: PropTypes.arrayOf(PropTypes.object).isRequired,
  androidFilter: PropTypes.array,
  iosCategories: PropTypes.arrayOf(PropTypes.object).isRequired,
  iosFilter: PropTypes.array,
  platform: PropTypes.string.isRequired,
  onCategoryUpdate: PropTypes.func.isRequired,
};

CategoriesFilter.defaultProps = {
  title: 'Categories:',
  androidFilter: [],
  iosFilter: [],
};

export default CategoriesFilter;
