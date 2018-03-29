import React from 'react';
import PropTypes from 'prop-types';
import { Tag } from 'antd';

const FilterCountLabel = ({ count }) => {
  if (count > 0) {
    return (
      <Tag className="filter-count-label" color="blue">
        {`${count} filter${count > 1 ? 's' : ''}`}
      </Tag>
    );
  }

  return null;
};

FilterCountLabel.propTypes = {
  count: PropTypes.number.isRequired,
};

export default FilterCountLabel;
