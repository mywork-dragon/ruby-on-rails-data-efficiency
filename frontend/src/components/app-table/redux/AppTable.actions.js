import { action, namespaceActions } from 'utils/action.utils';

const appTableActionTypes = [
  'LOAD_APPS',
  'CLEAR_APPS',
  'TOGGLE_ITEM',
  'TOGGLE_ALL_ITEMS',
];

export const createAppTableActionTypes = base => namespaceActions(base, appTableActionTypes);

export function createAppTableActions (types) {
  return {
    loadApps: apps => action(types.LOAD_APPS, { apps }),
    toggleItem: item => action(types.TOGGLE_ITEM, { item }),
    toggleAllItems: () => action(types.TOGGLE_ALL_ITEMS),
  };
}
