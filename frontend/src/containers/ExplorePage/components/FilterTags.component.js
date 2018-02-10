import React from 'react';
import PropTypes from 'prop-types';

const FilterTags = ({ deleteFilter, filters }) => (
  <div className="filter-tags-container">
    {
      filters
    }
  </div>
);

FilterTags.propTypes = {
  deleteFilter: PropTypes.func.isRequired,
  filters: PropTypes.object.isRequired,
};

export default FilterTags;
