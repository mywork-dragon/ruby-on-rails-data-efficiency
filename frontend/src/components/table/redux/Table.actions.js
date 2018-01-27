import { action, namespaceActions } from 'utils/action.utils';

const tableActionTypes = [
  'LOAD_RESULTS',
  'CLEAR_RESULTS',
  'TOGGLE_ITEM',
  'TOGGLE_ALL_ITEMS',
];

export const createTableActionTypes = base => namespaceActions(base, tableActionTypes);

export function createTableActions (types) {
  return {
    loadResults: results => action(types.LOAD_RESULTS, { results }),
    toggleItem: item => action(types.TOGGLE_ITEM, { item }),
    toggleAllItems: () => action(types.TOGGLE_ALL_ITEMS),
  };
}
