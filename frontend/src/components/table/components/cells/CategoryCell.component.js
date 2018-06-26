import React from 'react';
import PropTypes from 'prop-types';

const CategoryCell = ({
  requestCategories,
  shouldFetchCategories,
  getCategoryById,
  categories,
  platform,
}) => {
  if (shouldFetchCategories) requestCategories();

  if (Array.isArray(categories) && categories.length) {
    return <div>{categories.join(', ')}</div>;
  } else if (typeof categories === 'string') {
    return (
      <div style={{ margin: 5 }}>
        {getCategoryById(categories, platform).name}
      </div>
    );
  }

  return <span className="invalid">No data</span>;
};

CategoryCell.propTypes = {
  categories: PropTypes.oneOfType([PropTypes.array, PropTypes.string]),
  requestCategories: PropTypes.func.isRequired,
  shouldFetchCategories: PropTypes.bool.isRequired,
  getCategoryById: PropTypes.func.isRequired,
  platform: PropTypes.string.isRequired,
};

CategoryCell.defaultProps = {
  categories: '',
};

export default CategoryCell;
