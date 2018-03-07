import React from 'react';
import PropTypes from 'prop-types';
import { capitalize } from 'utils/format.utils';
import { Radio } from 'antd';

const PriceFilter = ({
  filter: {
    value,
  },
  panelKey,
  updateFilter,
}) => (
  <li>
    <label className="filter-label">
      Price:
    </label>
    {
      ['free', 'paid'].map(option => (
        <Radio
          key={option}
          checked={value === option}
          onClick={updateFilter('price', option, { panelKey })}
          type="radio"
          value={option}
        >
          {capitalize(option)}
        </Radio>
      ))
    }
  </li>
);

PriceFilter.propTypes = {
  filter: PropTypes.shape({
    value: PropTypes.string,
  }),
  panelKey: PropTypes.string.isRequired,
  updateFilter: PropTypes.func.isRequired,
};

PriceFilter.defaultProps = {
  filter: {
    value: '',
  },
};

export default PriceFilter;
