import React from 'react';
import PropTypes from 'prop-types';

import TableHeaderItem from './TableHeaderItem.component';

const TableHeader = ({ allSelected, headers, toggleAll }) => (
  <thead>
    <tr>
      { headers.map(item => <TableHeaderItem key={item} allSelected={allSelected} item={item} toggleAll={toggleAll} />) }
    </tr>
  </thead>
);

TableHeader.propTypes = {
  allSelected: PropTypes.bool,
  headers: PropTypes.arrayOf(PropTypes.string).isRequired,
  toggleAll: PropTypes.func,
};

TableHeader.defaultProps = {
  allSelected: false,
  toggleAll: null,
};

export default TableHeader;
