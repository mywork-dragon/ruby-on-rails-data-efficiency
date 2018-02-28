import React from 'react';
import PropTypes from 'prop-types';
import FilterTag from './FilterTag.component';

const FilterTagsDisplay = ({
  filters,
  ...rest
}) => (
  <div className="filter-tags-container">
    {
      Object.keys(filters).map((filterKey) => {
        if (filterKey === 'sdks') {
          return filters[filterKey].filters.map((x, idx) => (
            <FilterTag
              key={`${filterKey}${idx}`}
              displayText={x.displayText}
              filterKey={filterKey}
              index={idx}
              panelKey={x.panelKey}
              {...rest}
            />
          ));
        }
        return (
          <FilterTag
            key={filterKey}
            displayText={filters[filterKey].displayText}
            filterKey={filterKey}
            panelKey={filters[filterKey].panelKey}
            {...rest}
          />
        );
      })
    }
  </div>
);

FilterTagsDisplay.propTypes = {
  filters: PropTypes.object.isRequired,
};

export default FilterTagsDisplay;
