import React from 'react';
import PropTypes from 'prop-types';
import CategoriesDropdown from './CategoriesDropdown.component';

const CategoriesFilter = ({
  androidCategories,
  androidFilter,
  iosCategories,
  iosFilter,
  platform,
  ...rest
}) => (
  <li>
    <label className="filter-label">
      Categories:
    </label>
    <div className="input-group">
      <CategoriesDropdown categories={iosCategories} filter={iosFilter} platform="ios" selectedPlatform={platform} {...rest} />
      <CategoriesDropdown categories={androidCategories} filter={androidFilter} platform="android" selectedPlatform={platform} {...rest} />
    </div>
  </li>
);

CategoriesFilter.propTypes = {
  androidCategories: PropTypes.arrayOf(PropTypes.object).isRequired,
  androidFilter: PropTypes.shape({
    value: PropTypes.array,
  }),
  iosCategories: PropTypes.arrayOf(PropTypes.object).isRequired,
  iosFilter: PropTypes.shape({
    value: PropTypes.array,
  }),
  platform: PropTypes.string.isRequired,
};

CategoriesFilter.defaultProps = {
  androidFilter: {
    value: [],
  },
  iosFilter: {
    value: [],
  },
};

export default CategoriesFilter;
