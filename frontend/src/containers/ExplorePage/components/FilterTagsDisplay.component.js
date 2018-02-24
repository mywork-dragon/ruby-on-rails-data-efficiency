import React from 'react';
import PropTypes from 'prop-types';
import FilterTag from './FilterTag.component';

const FilterTagsDisplay = ({
  filters,
  ...rest
}) => (
  <div className="filter-tags-container">
    {
      Object.keys(filters).map(filterKey => (
        <FilterTag
          key={filterKey}
          displayText={filters[filterKey].displayText}
          filterKey={filterKey}
          panelKey={filters[filterKey].panelKey}
          {...rest}
        />
      ))
    }
  </div>
);

FilterTagsDisplay.propTypes = {
  filters: PropTypes.object.isRequired,
};

export default FilterTagsDisplay;
