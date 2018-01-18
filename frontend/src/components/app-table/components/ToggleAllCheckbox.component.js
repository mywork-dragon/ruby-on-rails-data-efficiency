import React from 'react';
import PropTypes from 'prop-types';

const ToggleAllCheckbox = ({ toggleAll, allSelected }) => (
  <th>
    <div className="selectAllCheckboxHeader">
      <input checked={allSelected} onChange={toggleAll} type="checkbox" />
    </div>
  </th>
);

ToggleAllCheckbox.propTypes = {
  toggleAll: PropTypes.func.isRequired,
  allSelected: PropTypes.bool.isRequired,
};

export default ToggleAllCheckbox;
