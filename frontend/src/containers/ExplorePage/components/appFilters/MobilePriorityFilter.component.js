import React from 'react';
import PropTypes from 'prop-types';

const MobilePriorityFilter = () => (
  <li>
    <label className="filter-label">
      Mobile Priority:
    </label>
    {
      ['Low', 'Medium', 'High'].map(option => (
        <label key={option} className="explore-checkbox">
          <input type="checkbox" value={option.toLowerCase()} />
          <span>{option}</span>
        </label>
      ))
    }
  </li>
);

export default MobilePriorityFilter;
