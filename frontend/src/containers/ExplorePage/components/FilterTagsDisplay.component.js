import React from 'react';
import PropTypes from 'prop-types';
import { capitalize } from 'utils/format.utils';
import FilterTag from './FilterTag.component';

const FilterTagsDisplay = ({
  filters,
  platform,
  includeTakenDown,
  updateFilter,
  ...rest
}) => (
  <div className="filter-tags-container">
    <FilterTag displayText={`Platform: ${capitalize(platform)}`} />
    {includeTakenDown && <FilterTag deleteFilter={updateFilter('includeTakenDown')} displayText="Include Taken Down Apps" filterKey="includeTakenDown" />}
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
  platform: PropTypes.string.isRequired,
  includeTakenDown: PropTypes.bool.isRequired,
  updateFilter: PropTypes.func.isRequired,
};

export default FilterTagsDisplay;
