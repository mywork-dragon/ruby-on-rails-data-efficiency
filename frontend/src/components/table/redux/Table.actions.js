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
  'CSV_EXPORTED',
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
    csvExported: () => action(types.CSV_EXPORTED),
    updateColumns: (columns, type) => action(types.UPDATE_COLUMNS, { columns, type }),
    updateFilter: (parameter, value, options) => action(types.UPDATE_FILTER, { parameter, value, options }),
    updatePageSize: newSize => action(types.UPDATE_PAGE_SIZE, { newSize }),
  };
}

export function createTableRequestActions (types) {
  return {
    allItems: {
      request: params => action(types.ALL_ITEMS.REQUEST, { params }),
      success: data => action(types.ALL_ITEMS.SUCCESS, { data }),
      failure: (error, data) => action(types.ALL_ITEMS.FAILURE, { error, data }),
    },
  };
}

export const UPDATE_DEFAULT_PAGE_SIZE = 'UPDATE_DEFAULT_PAGE_SIZE';
export const updateDefaultPageSize = pageSize => action(UPDATE_DEFAULT_PAGE_SIZE, { pageSize });


export const PUBLISHERS_CONTACTS_CSV_EXPORT_START = 'PUBLISHERS_CONTACTS_CSV_EXPORT_START';
export const PUBLISHERS_CONTACTS_CSV_EXPORT_FINISH = 'PUBLISHERS_CONTACTS_CSV_EXPORT_FINISH';
export const getPublishersContactsExportCsv = id => action(PUBLISHERS_CONTACTS_CSV_EXPORT_START, { id });
export const getPublishersContactsExportCsvFinish = () => action(PUBLISHERS_CONTACTS_CSV_EXPORT_FINISH);
