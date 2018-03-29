import React from 'react';
import PropTypes from 'prop-types';
import { Tag } from 'antd';

const FilterTag = ({
  deleteFilter,
  displayText,
  filterKey,
  index,
}) => {
  if (!displayText || displayText === '') {
    return null;
  }

  return (
    <Tag afterClose={() => deleteFilter(filterKey, index)} className="filter-tag-label" closable color="blue">
      {displayText}
    </Tag>
  );
};

FilterTag.propTypes = {
  deleteFilter: PropTypes.func.isRequired,
  displayText: PropTypes.string,
  filterKey: PropTypes.string.isRequired,
  index: PropTypes.number,
};

FilterTag.defaultProps = {
  displayText: '',
  index: null,
};

export default FilterTag;
