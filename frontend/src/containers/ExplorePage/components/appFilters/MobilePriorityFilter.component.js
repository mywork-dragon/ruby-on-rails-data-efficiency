import React from 'react';
import PropTypes from 'prop-types';
import { capitalize } from 'utils/format.utils';
import { Checkbox } from 'antd';

const MobilePriorityFilter = ({
  mobilePriority: {
    value,
  },
  panelKey,
  updateFilter,
}) => (
  <li className="li-filter">
    <label className="filter-label">
      Mobile Priority:
    </label>
    <div className="input-group">
      {
        ['low', 'medium', 'high'].map(option => (
          <Checkbox
            key={option}
            checked={value.includes(option)}
            onChange={updateFilter('mobilePriority', option, { panelKey })}
          >
            {capitalize(option)}
          </Checkbox>
        ))
      }
    </div>
  </li>
);

MobilePriorityFilter.propTypes = {
  mobilePriority: PropTypes.shape({
    value: PropTypes.arrayOf(PropTypes.string),
  }),
  panelKey: PropTypes.string.isRequired,
  updateFilter: PropTypes.func.isRequired,
};

MobilePriorityFilter.defaultProps = {
  mobilePriority: {
    value: [],
  },
};

export default MobilePriorityFilter;
