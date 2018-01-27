import React from 'react';
import PropTypes from 'prop-types';

const CheckboxCell = ({ toggleItem, isSelected }) => (
  <input checked={isSelected} onChange={toggleItem} type="checkbox" />
);

CheckboxCell.propTypes = {
  toggleItem: PropTypes.func.isRequired,
  isSelected: PropTypes.bool.isRequired,
};

export default CheckboxCell;
