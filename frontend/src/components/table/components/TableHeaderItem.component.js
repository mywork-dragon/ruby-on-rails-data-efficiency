import React from 'react';
import PropTypes from 'prop-types';

import ToggleAllCheckboxComponent from 'Table/components/headerCells/ToggleAllCheckbox.component';

const TableHeaderItem = ({ allSelected, item, toggleAll }) => {
  if (item === 'checkbox') {
    return (
      <th>
        <ToggleAllCheckboxComponent allSelected={allSelected} toggleAll={toggleAll} />
      </th>
    );
  }

  return (
    <th>
      <div className="th normal-right-padding">
        {item}
      </div>
    </th>
  );
};

TableHeaderItem.propTypes = {
  allSelected: PropTypes.bool.isRequired,
  item: PropTypes.string.isRequired,
  toggleAll: PropTypes.func,
};

TableHeaderItem.defaultProps = {
  toggleAll: null,
};

export default TableHeaderItem;
