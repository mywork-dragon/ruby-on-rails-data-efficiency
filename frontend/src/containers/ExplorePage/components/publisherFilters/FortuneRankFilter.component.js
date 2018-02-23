import React from 'react';
import PropTypes from 'prop-types';

const FortuneRankFilter = ({
  fortuneRank: {
    value,
  },
  updateFilter,
}) => (
  <li>
    <label className="filter-label">
      Fortune Rank:
    </label>
    <div className="input-group">
      {
        [500, 1000].map(option => (
          <label key={option} className="explore-checkbox">
            <input
              checked={value === option}
              name="fortuneRank"
              onClick={updateFilter('fortuneRank', option)}
              type="radio"
              value={option}
            />
            <span>{option}</span>
          </label>
        ))
      }
    </div>
  </li>
);

FortuneRankFilter.propTypes = {
  fortuneRank: PropTypes.shape({
    value: PropTypes.number,
  }),
  updateFilter: PropTypes.func.isRequired,
};

FortuneRankFilter.defaultProps = {
  fortuneRank: {
    value: 0,
  },
};

export default FortuneRankFilter;
