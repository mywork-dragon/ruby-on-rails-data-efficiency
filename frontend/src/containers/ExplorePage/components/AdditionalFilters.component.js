import React from 'react';
import PropTypes from 'prop-types';

const AdditionalFilters = ({ includeTakenDown, updateFilter }) => (
  <div className="basic-filter">
    <h4>
      Additional Settings
    </h4>
    <div className="additional-filters">
      <input checked={includeTakenDown} onChange={updateFilter('includeTakenDown')} type="checkbox" />
      Include unavailable apps
    </div>
  </div>
);

AdditionalFilters.propTypes = {
  includeTakenDown: PropTypes.bool.isRequired,
  updateFilter: PropTypes.func.isRequired,
};

export default AdditionalFilters;
