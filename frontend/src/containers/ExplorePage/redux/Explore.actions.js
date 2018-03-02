import { action, createRequestTypes } from 'utils/action.utils';

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

export const UPDATE_QUERY_ID = 'UPDATE_QUERY_ID';
export const updateQueryId = id => action(UPDATE_QUERY_ID, { id });

export const POPULATE_FROM_QUERY_ID = createRequestTypes('POPULATE_FROM_QUERY_ID');
export const populateFromQueryId = {
  request: id => action(POPULATE_FROM_QUERY_ID.REQUEST, { id }),
  success: (id, formState) => action(POPULATE_FROM_QUERY_ID.SUCCESS, { id, formState }),
  failure: () => action(POPULATE_FROM_QUERY_ID.FAILURE),
};

export const ADD_BLANK_SDK_FILTER = 'ADD_BLANK_SDK_FILTER';
export const addBlankSdkFilter = () => action(ADD_BLANK_SDK_FILTER);

export const DUPLICATE_SDK_FILTER = 'DUPLICATE_SDK_FILTER';
export const duplicateSdkFilter = index => action(DUPLICATE_SDK_FILTER, { index });
