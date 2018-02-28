import React from 'react';
import PropTypes from 'prop-types';
import { Label } from 'react-bootstrap';

const FilterTag = ({
  deleteFilter,
  displayText,
  filterKey,
  index,
  panelKey,
  updateActivePanel,
}) => {
  if (displayText === '') {
    return null;
  }

  const handleDelete = () => (e) => {
    e.stopPropagation();
    deleteFilter(filterKey, index);
  };

  return (
    <Label bsClass="label filter-tag-label" onClick={() => updateActivePanel(panelKey)}>
      {displayText}
      {' '}
      <i className="fa fa-times" onClick={handleDelete()} />
    </Label>
  );
};

FilterTag.propTypes = {
  deleteFilter: PropTypes.func.isRequired,
  displayText: PropTypes.string.isRequired,
  filterKey: PropTypes.string.isRequired,
  index: PropTypes.number,
  panelKey: PropTypes.string.isRequired,
  updateActivePanel: PropTypes.func.isRequired,
};

FilterTag.defaultProps = {
  index: null,
};

export default FilterTag;
