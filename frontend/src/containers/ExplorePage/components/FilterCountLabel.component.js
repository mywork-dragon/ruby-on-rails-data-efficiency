import React from 'react';
import PropTypes from 'prop-types';
import { Label } from 'react-bootstrap';

const FilterCountLabel = ({ count }) => {
  if (count > 0) {
    return (
      <Label className="label filter-count-label">
        {`${count} filter${count > 1 ? 's' : ''}`}
      </Label>
    );
  }

  return null;
};

FilterCountLabel.propTypes = {
  count: PropTypes.number.isRequired,
};

export default FilterCountLabel;
