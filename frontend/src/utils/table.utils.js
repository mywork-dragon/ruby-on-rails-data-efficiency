import React from 'react';
import ToggleAllCheckbox from 'Table/components/headerCells/ToggleAllCheckbox.component';
import CheckboxCell from 'Table/components/cells/CheckboxCell.component';
import { columnModels } from 'Table/redux/column.models';

export function generateColumns (headers, selectedItems, allSelected, toggleItem, toggleAll) {
  const columns = headers.map(x => columnModels.find(y => y.id === x));
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
    Cell: cell => (
      <CheckboxCell
        isSelected={selectedItems.some(x => x.id === cell.original.id && x.type === cell.original.type)}
        toggleItem={() => toggleItem(cell.original.id, cell.original.type)}
      />
    ),
  };
}
