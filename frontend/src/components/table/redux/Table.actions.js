import { action, namespaceActions, buildBaseRequestTypes } from 'utils/action.utils';

const tableActionTypes = [
  'TOGGLE_ITEM',
  'TOGGLE_ALL_ITEMS',
  'UPDATE_COLUMNS',
  'UPDATE_FILTER',
  'CLEAR_FILTERS',
];

const tableRequestTypes = [
  'ALL_ITEMS',
];

export const createTableActionTypes = base => namespaceActions(base, tableActionTypes);
export const createTableRequestTypes = base => buildBaseRequestTypes(base, tableRequestTypes);

export function createTableActions (types) {
  return {
    clearFilters: () => action(types.CLEAR_FILTERS),
    toggleItem: item => action(types.TOGGLE_ITEM, { item }),
    toggleAllItems: () => action(types.TOGGLE_ALL_ITEMS),
    updateColumns: columns => action(types.UPDATE_COLUMNS, { columns }),
    updateFilter: (parameter, value) => action(types.UPDATE_FILTER, { parameter, value }),
  };
}

export function createTableRequestActions (types) {
  return {
    allItems: {
      request: params => action(types.ALL_ITEMS.REQUEST, { params }),
      success: data => action(types.ALL_ITEMS.SUCCESS, { data }),
      failure: () => action(types.ALL_ITEMS.FAILURE),
    },
  };
}

export const UPDATE_PAGE_SIZE = 'UPDATE_PAGE_SIZE';
export const updatePageSize = pageSize => action(UPDATE_PAGE_SIZE, { pageSize });
