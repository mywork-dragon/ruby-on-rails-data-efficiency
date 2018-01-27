import React from 'react';
import PropTypes from 'prop-types';

const ToggleAllCheckbox = ({ toggleAll, allSelected, addClass }) => (
  <div className={addClass ? 'selectAllCheckboxHeader' : ''}>
    <input checked={allSelected} onChange={toggleAll} type="checkbox" />
  </div>
);

ToggleAllCheckbox.propTypes = {
  addClass: PropTypes.bool,
  allSelected: PropTypes.bool.isRequired,
  toggleAll: PropTypes.func.isRequired,
};

ToggleAllCheckbox.defaultProps = {
  addClass: true,
};

export default ToggleAllCheckbox;
