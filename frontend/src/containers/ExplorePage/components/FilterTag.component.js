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
    <Tag
      afterClose={() => deleteFilter(filterKey, index)}
      className="filter-tag-label"
      closable={deleteFilter && filterKey}
      color="blue"
    >
      {displayText}
    </Tag>
  );
};

FilterTag.propTypes = {
  deleteFilter: PropTypes.func,
  displayText: PropTypes.string,
  filterKey: PropTypes.string,
  index: PropTypes.number,
};

FilterTag.defaultProps = {
  deleteFilter: null,
  displayText: '',
  filterKey: null,
  index: null,
};

export default FilterTag;
