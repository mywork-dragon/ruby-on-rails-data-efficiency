import React from 'react';
import PropTypes from 'prop-types';

const AvailableCountriesFilter = () => (
  <li>
    <label className="filter-label">
      Available in:
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

export default AvailableCountriesFilter;
