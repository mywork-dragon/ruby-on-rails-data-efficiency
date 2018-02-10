import React from 'react';
import PropTypes from 'prop-types';

const PriceFilter = () => (
  <li>
    <label className="filter-label">
      Price:
    </label>
    {
      ['Free', 'Paid'].map(option => (
        <label key={option} className="explore-checkbox">
          <input type="checkbox" value={option.toLowerCase()} />
          <span>{option}</span>
        </label>
      ))
    }

  </li>
);

export default PriceFilter;
