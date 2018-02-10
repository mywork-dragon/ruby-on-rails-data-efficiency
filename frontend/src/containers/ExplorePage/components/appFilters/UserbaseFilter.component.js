import React from 'react';
import PropTypes from 'prop-types';

const UserbaseFilter = () => (
  <li>
    <label className="filter-label">
      Userbase:
    </label>
    {
      ['Weak', 'Moderate', 'Strong', 'Elite'].map(option => (
        <label key={option} className="explore-checkbox">
          <input type="checkbox" value={option.toLowerCase()} />
          <span>{option}</span>
        </label>
      ))
    }
  </li>
);

export default UserbaseFilter;
