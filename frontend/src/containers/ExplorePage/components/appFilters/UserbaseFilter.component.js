import React from 'react';
import PropTypes from 'prop-types';
import { capitalize } from 'utils/format.utils';
import { Checkbox } from 'antd';

const UserbaseFilter = ({
  panelKey,
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
          <Checkbox
            checked={value.includes(option)}
            onChange={updateFilter('userBase', option, { panelKey })}
          >
            {capitalize(option)}
          </Checkbox>
        ))
      }
    </div>
  </li>
);

UserbaseFilter.propTypes = {
  panelKey: PropTypes.string.isRequired,
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
