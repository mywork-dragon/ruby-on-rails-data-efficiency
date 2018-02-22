import React from 'react';
import PropTypes from 'prop-types';

const AvailableCountriesFilter = () => (
  <li>
    <label className="filter-label">
      Available in:
    </label>
    <div className="input-group">
      <select>
        {
          ['All', 'Any', 'None'].map(option => (
            <option key={option} value={option.toLowerCase()}>{option}</option>
          ))
        }
      </select>
      <input placeholder="Type a country" type="text" />
    </div>
  </li>
);

export default AvailableCountriesFilter;
