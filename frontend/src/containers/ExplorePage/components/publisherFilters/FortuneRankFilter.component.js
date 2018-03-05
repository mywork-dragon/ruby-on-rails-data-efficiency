import React from 'react';
import PropTypes from 'prop-types';
import { Radio } from 'antd';

const FortuneRankFilter = ({
  fortuneRank: {
    value,
  },
  panelKey,
  updateFilter,
}) => (
  <li>
    <label className="filter-label">
      Fortune Rank:
    </label>
    <div className="input-group">
      {
        [500, 1000].map(option => (
          <Radio
            checked={value === option}
            name="fortuneRank"
            onClick={updateFilter('fortuneRank', option, { panelKey })}
            type="radio"
            value={option}
          >
            {option}
          </Radio>
        ))
      }
    </div>
  </li>
);

FortuneRankFilter.propTypes = {
  fortuneRank: PropTypes.shape({
    value: PropTypes.number,
  }),
  panelKey: PropTypes.string.isRequired,
  updateFilter: PropTypes.func.isRequired,
};

FortuneRankFilter.defaultProps = {
  fortuneRank: {
    value: 0,
  },
};

export default FortuneRankFilter;
