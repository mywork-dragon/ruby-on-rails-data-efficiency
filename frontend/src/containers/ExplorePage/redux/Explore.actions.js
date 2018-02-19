import { action } from 'utils/action.utils';

import {
  createTableActionTypes,
  createTableActions,
  createTableRequestTypes,
  createTableRequestActions,
} from 'Table/redux/Table.actions';

export const EXPLORE_TABLE_ACTION_TYPES = createTableActionTypes('explorePage');
export const exploreTableActions = createTableActions(EXPLORE_TABLE_ACTION_TYPES);

export const EXPLORE_TABLE_REQUEST_TYPES = createTableRequestTypes('explorePage');
export const exploreTableRequestActions = createTableRequestActions(EXPLORE_TABLE_REQUEST_TYPES);

export const TABLE_TYPES = Object.assign({}, EXPLORE_TABLE_ACTION_TYPES, EXPLORE_TABLE_REQUEST_TYPES);
export const tableActions = Object.assign({}, exploreTableActions, exploreTableRequestActions);

export const TOGGLE_FORM = 'TOGGLE_FORM';
export const toggleForm = () => action(TOGGLE_FORM);

export const UPDATE_ACTIVE_PANEL = 'UPDATE_ACTIVE_PANEL';
export const updateActivePanel = index => action(UPDATE_ACTIVE_PANEL, { index });
