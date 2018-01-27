import { createTableActionTypes, createTableActions } from 'Table/redux/Table.actions';

export const EXPLORE_TABLE_ACTION_TYPES = createTableActionTypes('explore');
export const exploreTableActions = createTableActions(EXPLORE_TABLE_ACTION_TYPES);
