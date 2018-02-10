import React from 'react';
import PropTypes from 'prop-types';

const FortuneRankFilter = () => (
  <li>
    <label className="filter-label">
      Fortune Rank:
    </label>
    {
      [500, 1000].map(option => (
        <label key={option} className="explore-checkbox">
          <input type="checkbox" value={option} />
          <span>{option}</span>
        </label>
      ))
    }
  </li>
);

export default FortuneRankFilter;
