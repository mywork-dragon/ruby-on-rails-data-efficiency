import React from 'react';
import { $localStorage } from 'utils/localStorage.utils';
import ToggleAllCheckbox from 'Table/components/headerCells/ToggleAllCheckbox.component';
import CheckboxCell from 'Table/components/cells/CheckboxCell.component';
import { columnModels } from 'Table/redux/column.models';

export function initializeColumns (columns, activeColumns, lockedColumns) {
  const res = {};
  columns.forEach((column) => {
    if (lockedColumns && lockedColumns.includes(column)) {
      res[column] = 'LOCKED';
    } else {
      res[column] = activeColumns ? activeColumns.includes(column) : true;
    }
  });
  return res;
}

export function totalNumPages (resultsCount, pageSize) {
  return Math.ceil(resultsCount / pageSize);
}

export function generateColumns (headers, selectedItems, allSelected, toggleItem, toggleAll) {
  const headerCells = Object.keys(headers).filter(key => headers[key]);
  const columns = headerCells.map(x => columnModels.find(y => y.id === x));
  if (selectedItems && toggleItem && toggleAll) {
    const checkbox = createCheckboxModel(selectedItems, allSelected, toggleItem, toggleAll);
    columns.unshift(checkbox);
  }

  return columns;
}

function createCheckboxModel (selectedItems, allSelected, toggleItem, toggleAll) {
  return {
    Header: <ToggleAllCheckbox addClass={false} allSelected={allSelected} toggleAll={toggleAll} />,
    className: 'checkbox-cell',
    headerClassName: 'checkbox-cell',
    sortable: false,
    width: 40,
    Cell: cell => (
      <CheckboxCell
        isSelected={selectedItems.some(x => x.id === cell.original.id && x.type === cell.original.type)}
        toggleItem={toggleItem(cell.original.id, cell.original.type)}
      />
    ),
  };
}

export function setPreferredPageSize (pageSize) {
  $localStorage.set('tablePageSize', pageSize);
}

export function getPreferredPageSize () {
  return $localStorage.get('tablePageSize');
}
