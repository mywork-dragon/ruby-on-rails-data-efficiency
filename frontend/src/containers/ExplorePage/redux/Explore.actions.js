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
export const toggleForm = type => action(TOGGLE_FORM, { type });

export const TOGGLE_PANEL = 'TOGGLE_PANEL';
export const togglePanel = index => action(TOGGLE_PANEL, { index });

export const UPDATE_QUERY_ID = 'UPDATE_QUERY_ID';
export const updateQueryId = (id, formState) => action(UPDATE_QUERY_ID, { id, formState });

export const UPDATE_QUERY_RESULT_ID = 'UPDATE_QUERY_RESULT_ID';
export const updateQueryResultId = id => action(UPDATE_QUERY_RESULT_ID, { id });

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

export const GET_CSV_QUERY_ID = createRequestTypes('GET_CSV_QUERY_ID');
export const getCsvQueryId = {
  request: params => action(GET_CSV_QUERY_ID.REQUEST, { params }),
  success: id => action(GET_CSV_QUERY_ID.SUCCESS, { id }),
  failure: () => action(GET_CSV_QUERY_ID.FAILURE),
};

export const REQUEST_QUERY_PAGE = 'REQUEST_QUERY_PAGE';
export const requestQueryPage = (id, page) => action(REQUEST_QUERY_PAGE, { id, page });

export const TRACK_TABLE_SORT = 'TRACK_TABLE_SORT';
export const trackTableSort = sort => action(TRACK_TABLE_SORT, { sort });

export const UPDATE_SAVED_SEARCH_PAGE = 'UPDATED_SAVED_SEARCH_PAGE';
export const updateSavedSearchPage = page => action(UPDATE_SAVED_SEARCH_PAGE, { page });
