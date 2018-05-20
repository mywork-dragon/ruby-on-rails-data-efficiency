import React from 'react';
import PropTypes from 'prop-types';
import { Checkbox } from 'antd';

const AdditionalFilters = ({ includeTakenDown, updateFilter }) => (
  <div className="basic-filter">
    <h4>
      Additional Settings
    </h4>
    <div className="additional-filters">
      <Checkbox
        checked={includeTakenDown}
        className="explore-checkbox"
        onChange={updateFilter('includeTakenDown')}
      >
        Include apps that have been taken down
      </Checkbox>
    </div>
  </div>
);

AdditionalFilters.propTypes = {
  includeTakenDown: PropTypes.bool.isRequired,
  updateFilter: PropTypes.func.isRequired,
};

export default AdditionalFilters;
