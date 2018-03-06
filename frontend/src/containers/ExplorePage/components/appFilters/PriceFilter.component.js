import React from 'react';
import PropTypes from 'prop-types';
import { capitalize } from 'utils/format.utils';
import { Checkbox } from 'antd';

const PriceFilter = () => (
  <li>
    <label className="filter-label">
      Price:
    </label>
    {
      ['free', 'paid'].map(option => (
        <Checkbox key={option}>
          {capitalize(option)}
        </Checkbox>
      ))
    }
  </li>
);

export default PriceFilter;
