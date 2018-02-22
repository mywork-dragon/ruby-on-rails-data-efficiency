import React from 'react';
import PropTypes from 'prop-types';
import { capitalize } from 'utils/format.utils';

const UserbaseFilter = ({
  userBase: {
    value,
  },
  updateFilter,
}) => (
  <li>
    <label className="filter-label">
      Userbase:
    </label>
    <div className="input-group">
      {
        ['weak', 'moderate', 'strong', 'elite'].map(option => (
          <label key={option} className="explore-checkbox">
            <input
              checked={value.includes(option)}
              onChange={updateFilter('userBase', option)}
              type="checkbox"
              value={option}
            />
            <span>{capitalize(option)}</span>
          </label>
        ))
      }
    </div>
  </li>
);

UserbaseFilter.propTypes = {
  userBase: PropTypes.shape({
    value: PropTypes.arrayOf(PropTypes.string),
  }),
  updateFilter: PropTypes.func.isRequired,
};

UserbaseFilter.defaultProps = {
  userBase: {
    value: [],
  },
};

export default UserbaseFilter;
