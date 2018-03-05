import { action, namespaceActions, buildBaseRequestTypes } from 'utils/action.utils';

const tableActionTypes = [
  'CLEAR_FILTERS',
  'CLEAR_RESULTS',
  'DELETE_FILTER',
  'SET_LOADING',
  'TOGGLE_ITEM',
  'TOGGLE_ALL_ITEMS',
  'UPDATE_COLUMNS',
  'UPDATE_FILTER',
  'UPDATE_PAGE_SIZE',
];

const tableRequestTypes = [
  'ALL_ITEMS',
];

export const createTableActionTypes = base => namespaceActions(base, tableActionTypes);
export const createTableRequestTypes = base => buildBaseRequestTypes(base, tableRequestTypes);

export function createTableActions (types) {
  return {
    clearFilters: () => action(types.CLEAR_FILTERS),
    clearResults: () => action(types.CLEAR_RESULTS),
    deleteFilter: (filterKey, index) => action(types.DELETE_FILTER, { filterKey, index }),
    setLoading: state => action(types.SET_LOADING, { state }),
    toggleItem: item => action(types.TOGGLE_ITEM, { item }),
    toggleAllItems: () => action(types.TOGGLE_ALL_ITEMS),
    updateColumns: columns => action(types.UPDATE_COLUMNS, { columns }),
    updateFilter: (parameter, value, options) => action(types.UPDATE_FILTER, { parameter, value, options }),
    updatePageSize: pageSize => action(types.UPDATE_PAGE_SIZE, { pageSize }),
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

export const UPDATE_DEFAULT_PAGE_SIZE = 'UPDATE_DEFAULT_PAGE_SIZE';
export const updateDefaultPageSize = pageSize => action(UPDATE_DEFAULT_PAGE_SIZE, { pageSize });
