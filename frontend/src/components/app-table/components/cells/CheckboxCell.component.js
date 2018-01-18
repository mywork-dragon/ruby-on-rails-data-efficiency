import React from 'react';
import PropTypes from 'prop-types';

const CheckboxCell = ({ toggleItem, isSelected }) => (
  <td className="dashboardTableDataCheckbox">
    <input checked={isSelected} onChange={toggleItem} type="checkbox" />
  </td>
);

CheckboxCell.propTypes = {
  toggleItem: PropTypes.func.isRequired,
  isSelected: PropTypes.bool.isRequired,
};

export default CheckboxCell;
