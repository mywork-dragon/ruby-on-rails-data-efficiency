import React from 'react';
import PropTypes from 'prop-types';

const HeadquarterFilter = () => (
  <li>
    <label className="filter-label">
      Headquartered in:
    </label>
    <select>
      {
        ['All', 'Any', 'None'].map(option => (
          <option key={option} value={option.toLowerCase()}>{option}</option>
        ))
      }
    </select>
    <input placeholder="Type a country" type="text" />
  </li>
);

export default HeadquarterFilter;
